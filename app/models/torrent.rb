require 'ftools'
require 'fileutils_monkeypatch'
require 'rubytorrent'
require 'net/http'
require 'uri'
class Torrent < ActiveRecord::Base
  include FileUtils
  has_many :watchings, :dependent => true
  has_many :users, :through => :watchings
  belongs_to :feed
  validates_uniqueness_of :filename, :allow_nil => true
  validates_format_of :url, :with => URI.regexp, :if => :remote?

  before_update :notify_if_just_finished
  before_save :sync
  before_validation :fix_filename, :auto_set_status
  after_create :notify_users_and_add_it
  before_create :set_default_values

  acts_as_ferret :fields => [:title, :filename, :url, :tag_list], :remote => true

  acts_as_taggable

  STATES = [:running,:fetching,:paused,:archived,:remote,:stopping]

  # lets simulate the state machine
  def current_state
    status ? status.to_sym : :nostatus
  end
  def status=(new_status)
    self[:status] = new_status.to_s
  end
  def self.states
    STATES
  end
  STATES.each do |st|
    src = <<-END_SRC
      def #{st.to_s}?
        current_state == :#{st}
      end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end

  
  def pause!
    event_from :running do 
      moveto( fullpath(:paused) )
      brake
      update_attribute(:status, :paused)
    end
  end

  def start!
    event_from [:paused, :archived, :fetching, :running] do 
      unarchive_content
      moveto( fullpath(:running) )
      update_attribute(:status, :running)
      save
    end
  end

  def stop!
    event_from [:paused, :running, :stopping] do
      if current_state != :stopping
        moveto( fullpath(:stopping) ) 
        update_attribute(:status, :stopping)
        archive_content
      end
      moveto( fullpath(:archived) )
      update_attribute(:status, :archived)
    end
  end

  def halt!
    event_from [:paused, :running, :stopping, :fetching] do
      moveto( fullpath(:archived) ) && update_attribute(:status,:archived)
      true
    end
  end

  def fetch!
    event_from [:remote] do
      update_attribute(:status, :fetching)
      fetch_by_url
      moveto( fullpath(:archived) )
      update_attribute(:status, :archived)
    end
  end

  def fetch_and_start!
    fetch! && start!
  end

  def self.invalid
    condition = 'NOT (' + self.class.states.collect { |s| "(status='#{s.to_s}')"}.join(' OR ') + ')'
    find(:all, :conditions => condition, :order => 'created_at')
  end

  def self.running
    find_in_state(:running, :order => 'created_at desc')
  end

  def self.find_in_state(state, opts={})
    find_all_by_status(state.to_s,opts)
  end

  def self.find_collection(ids)
    return [] unless ids
    return [] if ids.empty?
    find_all_by_id(ids)
  end
  def self.find_by_term_and_tags(term,tagstring)
    query = term.blank? ? '' : term.split(/ /).map { |s| "*#{s}*"}.join(' ')
    unless query.blank?
      query = "(#{query} OR tag_list:(#{query}))"
    end
    unless tagstring.blank?
      tagnames = Tag.parse(tagstring) || []
      query += " tag_list:(#{tagnames.join(' ')})"
    end
    logger.debug("Ferret search for [#{query}]")
    find_with_ferret(query, {:limit => :all})
  end
  # aggregates
  def self.rate_up
    Torrent.sum('rate_up',:conditions => "status = 'running'") || 0
  end
  def self.rate_down
    Torrent.sum('rate_down',:conditions => "status = 'running'") || 0
  end
  def self.transferred_up
    Torrent.sum('transferred_up',:conditions => "status = 'running'") || 0
  end
  def self.transferred_down
    Torrent.sum('transferred_down',:conditions => "status = 'running'") || 0
  end
  def self.last_update
    Torrent.maximum('updated_at', :conditions => "status = 'running'") || 23.days.ago
  end

  # side info
  def self.diskfree(which=nil)
    dir = which || Settings.torrent_dir
    cmd = '/bin/df'
    if File.exists?(dir) and File.exists?(cmd)
      `#{cmd} '#{dir}'`.split[10].to_i
    else
      0
    end
  end

  def self.disksfree
    %w(torrent_dir history_dir target_dir).
      inject({}) { |hsh,dir| hsh.merge({ dir => Torrent.diskfree(Settings[dir]) }) }
  end


  # extended attributes
  def percent
    percent_done
  end

  def download_status
    if !errormsg.blank?
      "#{statusmsg} - #{errormsg}"
    elsif statusmsg =~ /[\d:]+/
      "#{statusmsg} remaining"
    elsif statusmsg.blank?
      "[unknown status]"
    else
      statusmsg
    end
  end

  # for fuse
  def content_root
    if content_single?
      content_filenames
    else
      content_filenames.map {|f| f.gsub /^.*?\//, ''} # strip the leading directory name
    end
  end

  def content_single?
    content_filenames.size == 1
  end

  def content_size
    self[:content_size].to_i
  end

  def has_files?
    !self[:content_filenames].blank?
  end

  def content_filenames
    @content_filenames ||= YAML.load(self[:content_filenames])
  rescue TypeError
  end

  def actual_size
    content_size * percent / 100
  end

  def fullpath(wanted_state=nil)
    wanted_state ||= current_state
    return 'no filename' unless filename
    return "bad status: #{status}" unless filepath_status[wanted_state]
    filepath_status[wanted_state]
  end

  # nice title 
  # 1) uses defined title or
  # 2) takes filename and
  # * removes some 1337 comments about format/group in the filename
  # * cuts the .torrent extention
  # * tranforms interpunctuations into spaces
  # * kills renaming spaces 
  # or
  # 3) takes a Title with the torrent's id
  def short_title
    title ||
      filename ? 
        filename.
          gsub(/(?:dvd|xvid|divx|hdtv|cam\b)/i,'').
          gsub(/\[.*?\]/,'').
          gsub(/\(.*?\)/,'').
          sub(/\d{5,}.TPB/,'').
          sub(/\.?torrent$/i,'').
          gsub(/[._-]+/,' ').
          gsub(/\s{2,}/,' ').rstrip.lstrip :
        "Torrent ##{id}"
  end
  # synonym for short_title
  def nice_title
    short_title
  end

  def file_exists?
    filename && fullpath && File.exists?(fullpath)
  end

  def remote?
    current_state == :remote
  end

  # set rates to 0
  def brake
    self.rate_up = 0
    self.rate_down = 0
  end

  def auto_set_status
    self.status= 
      unless file_exists?
        unless url.blank?
          :remote
        else
          status_by_file_location
        end
      else
        status
      end
  end

  def before_destroy
    File.delete(fullpath) if file_exists?
  end

  def files_hierarchy
    return {} unless metainfo
    return {metainfo.name => ''} if metainfo.single?
    return {} unless metainfo.files
    metainfo.files.
      map      { |file| file.path }.
      group_by { |path| path.first }
  end

  def set_metainfo
    return unless metainfo
    self[:content_size] = if metainfo.single?
      metainfo.length
    else
      metainfo.files.inject(0) { |sum, f| sum + f.length}
    end
    self[:content_filenames] = 
      if metainfo.single?
        [metainfo.name]
      else
        metainfo.files.map { |f| File.join(metainfo.name, f.path)}
      end
  end

  # Here lies the content while it is being downloaded
  def working_path
    return '' unless metainfo
    File.join(Settings.torrent_dir,metainfo.name)
  end

  # When a torrent is archived, the content will be moved here
  def target_path
    return '' unless metainfo
    File.join(Settings.target_dir,metainfo.name)
  end

  # where to find the contents, either #working_path or #target_path
  def content_path
    archived? ? target_path : working_path
  end

  # returns the current url to the content for the user
  # the user has to specify his moutpoints for that to happen
  def content_url(usr)
    return nil unless metainfo
    if archived?
      return File.join(usr.target_dir_mountpoint,metainfo.name) if usr.target_dir_mountpoint
    else
      return File.join(usr.content_dir_mountpoint,metainfo.name) if usr.content_dir_mountpoint
    end
    return nil
  end

  def finished?
    percent == 100 and statusmsg == 'seeding'
  end

  def downloading?
    statusmsg =~ /^[\d:]+$/ or (rate_down and rate_up and rate_down + rate_up > 0)
  end

  def available?
    peers >= 1 or distributed_copies >= 1
  end

  def metainfo
    begin
      if !@mii and file_exists?
        @mii = RubyTorrent::MetaInfo.from_location(fullpath).info
      end
    rescue # RubyTorrent::MetaInfoFormatError
      # no UDP supprt yet
      @mii = nil
    end
    @mii
  end
 
  def uri
    if @uri
      @uri
    else
      u = url
      u = URI.escape u
      u = URI.escape u, /[\[\]]/
      @uri = URI.parse(u)
    end
  end

  def fetchable?
    Net::HTTP.start(uri.host, uri.port) do |http|
      resp = http.head(uri.path)
      if resp.is_a?(Net::HTTPSuccess) and (resp['content-type'] =~ /application\/x-bittorrent/i)
        return resp
      else
        errors.add :url, "HTTP Error: #{resp.inspect}, Content-type: #{resp['content-type']}"
        return false
      end
    end
  rescue URI::InvalidURIError
    errors.add :url, "is not valid (#{url.to_s})"
    return false
  rescue SocketError, NoMethodError => e
    errors.add :url, "unfetchable (#{e.to_s})"
    return false
  end

  def fetch_by_url
    if resp = Net::HTTP::get_response(uri) and resp.is_a?(Net::HTTPSuccess)
      unless filename
        fn = if cdis = resp['content-disposition']
               cdis.sub(/^.*filename=(.+)$/,'\1').
                    sub(/^"+/, '').
                    sub(/"+$/, '')
             else
               url.sub(/.*\//,'')
             end
        fn += '.torrent' unless fn =~ /\.torrent$/
        update_attribute :filename, fn
      end
      File.open(fullpath(:fetching), 'w') do |file|
        file.write resp.body
      end
      return self
    else
      raise "could not fetch: #{resp.inspect}"
      return false
    end
  end

  def archive_content
    return unless metainfo
    begin
      move(working_path,target_path) if File.exists?(working_path)
    rescue Exception => e
      errors.add :filename, "^error on moving content: #{e.to_s}"
    end
  end

  def unarchive_content
    return unless metainfo
    begin
      move(target_path,working_path) if File.exists?(target_path)
    rescue Exception => e
      errors.add :filename, "^error on moving content: #{e.to_s}"
    end
  end

  def delete_content!
    return unless metainfo
    begin
      opfer = if archived?
                target_path
              else
                working_path
              end
      if File.exists?(opfer) 
        rm_rf(opfer) 
        true
      else
        errors.add :filename, "^content not found: #{opfer}"
        false
      end
    rescue Exception => e
      errors.add :filename, "^error on deleting content: #{e.to_s}"
    end
  end

  def moveto(target)
    source = fullpath
    return if source.blank?
    return if target.blank?
    return unless File.exists? source
    begin
      move(source,target)
    rescue Exception => e
      errors.add :filename, "^error while moving torrent: #{e.to_s}"
    end
  end

  def sync
    sync! if needs_to_be_synced?
  end

  def sync!
    set_metainfo && synced_at = Time.now
  end

  def needs_to_be_synced?
    synched_at.blank? || (Time.now - synched_at > 1.day)
  end

 private
  def filepath_status
    {
      :archived => File.join(Settings.history_dir, filename),
      :paused   => File.join(Settings.torrent_dir, filename) + '.paused',
      :fetching => File.join(Settings.torrent_dir, filename) + '.fetching',
      :stopping => File.join(Settings.torrent_dir, filename) + '.stopping',
      :running  => File.join(Settings.torrent_dir, filename),
      :remote   => ''
    }
  end

  def status_by_file_location
    filepath_status.select { |s,f| File.exists?(f) }.first.first
  rescue NoMethodError
    return :invalid
  end

  # removes the leading './' or path from the filename
  def fix_filename
    filename.sub!(/^.*\/([^\/]*)$/,'\1') if filename
  end

  def set_default_values
    self.status ||= 'running'
    self.content_size      ||= 0
    self.rate_down ||= 0
    self.rate_up   ||= 0
    self.seeds     ||= 0
    self.peers     ||= 0
    self.description     ||= ''
    self.percent_done    ||= 0
    self.transferred_up   ||= 0
    self.transferred_down ||= 0
  end

  # checks is the torrent was just finished downloading 
  # and notifies all subscripted users if this is the case
  def notify_if_just_finished
    if percent_done == 100
      old = Torrent.find(self.id)
      if old.percent_done < 100 and statusmsg == 'seeding'
        self.watchings.find_all_by_apprise(true).collect {|w| w.user }.each do |user| 
          Notifier.send_finished(user,self) if user.notifiable_via_jabber?
        end
      end
    end
  end

  # notifies the users that have +notify_on_new_torrents+ set and adds it to their watchlist
  def notify_users_and_add_it
    return true if remote?
    User.find_all_by_notify_on_new_torrents(true).each do |user|
      Notifier.send_new(user,self) if user.notifiable_via_jabber?
      user.watch(self) unless user.dont_watch_new_torrents?
    end
  end

  def event_from(old_states=[])
    old_states = [old_states] unless old_states.is_a? Array
    if old_states.empty? || old_states.include?(current_state)
      yield
    else
      raise RuntimeError, "#{current_state} is not a valid state for this transition"
    end
  end
end
