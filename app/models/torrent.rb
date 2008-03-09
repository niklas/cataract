# == Schema Information
# Schema version: 33
#
# Table name: torrents
#
#  id                :integer       not null, primary key
#  title             :string(255)   
#  description       :string(255)   
#  content_size      :string(255)   
#  filename          :string(255)   
#  hidden            :boolean       
#  command           :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#  status            :string(255)   
#  url               :text          
#  feed_id           :integer       
#  synched_at        :datetime      
#  content_filenames :text          
#  info_hash         :string(40)    
#  content_path      :string(2048)  
#

require 'ftools'
require 'fileutils_monkeypatch'
require 'rubytorrent'
require 'net/http'
require 'uri'
require 'rtorrent'
require 'rtorrent_proxy'

class Torrent < ActiveRecord::Base
  include FileUtils
  has_many :watchings, :dependent => :destroy
  has_many :users, :through => :watchings
  belongs_to :feed
  validates_uniqueness_of :filename, :allow_nil => true
  validates_format_of :info_hash, :with => /[0-9A-F]{40}/, :unless => :remote?
  validates_format_of :url, :with => URI.regexp, :if => :remote?

  before_update :notify_if_just_finished
  before_save :sync
  before_validation :fix_filename, :auto_set_status
  after_create :notify_users_and_add_it
  before_create :set_default_values
  def after_find
    check_if_status_is_up_to_date
  end

  acts_as_ferret :fields => [:title, :filename, :url, :tag_list], :remote => true

  acts_as_taggable

  STATES = [:running,:paused,:fetching,:new,:archived,:remote,:invalid]
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

  def status_from_rtorrent
    (remote.state ==  1 ? 'running' : 'paused')
  end

  
  def pause!
    event_from :running do 
      remote.stop!
      update_attribute(:status, :paused)
    end
  end

  def start!
    event_from [:paused, :archived, :new] do 
      # copy the file because rtorrent deletes file on #stop!
      moveto( :running, :copy => true )
      unless paused?
        remote.load(self.fullpath(:running))
        remote.directory = Settings.torrent_dir
      end
      remote.start!
      update_attribute(:status, :running)
    end
  end

  def stop!
    event_from [:paused, :running] do
      remote.stop!
      remote.close!
      remote.erase! # WARNING! will delete the torrent file
      finally_stop!
    end
  end

  def finally_stop!
    update_attribute(:status, :archived)
  end

  def fetch!
    event_from [:remote] do
      update_attribute(:status, :fetching)
      fetch_by_url
      moveto( :archived )
      update_attribute(:status, :archived)
    end
  end

  def fetch_and_start!
    fetch! && start!
  end

  def self.fetch_and_start_by_url(new_url)
    if t = create(:url => new_url, :status => 'remote')
      t.fetch! && t.start!
    end
    t
  end



  RTORRENT_METHODS = [:up_rate, :up_total, :down_rate, :down_total, :size_bytes, :message, :completed_bytes, :open?, :active?]

  def method_missing_with_xml_rpc(m, *args, &blk)
    if RTORRENT_METHODS.include?(m.to_sym) and remote
      remote.send m, *args, &blk
    else
      method_missing_without_xml_rpc m, *args, &blk
    end
  rescue TorrentNotRunning
    finally_stop! unless archived?
    return '[not-running]'
  rescue TorrentHasNoInfoHash
    return '[no-info_hash]'
  end
  alias_method_chain :method_missing, :xml_rpc

  def self.rtorrent
    @@rtorrent ||= RTorrent.new
  end

  def rtorrent
    self.class.rtorrent
  end

  def remote
    @remote ||= RTorrentProxy.new(self,rtorrent)
  end

  def self.invalid
    condition = 'NOT (' + self.class.states.collect { |s| "(status='#{s.to_s}')"}.join(' OR ') + ')'
    find(:all, :conditions => condition, :order => 'created_at')
  end

  def self.running
    find_in_state(:running, :order => 'created_at desc')
  end

  def self.find_in_state(state, opts={})
    opts.merge!  :order => 'created_at DESC'
    find_all_by_status(state.to_s,opts)
  end

  def self.find_recent(num=23)
    find(:all, :order => 'created_at DESC', :limit => num)
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
  def self.upload_rate
    rtorrent.upload_rate
  end
  def self.download_rate
    rtorrent.download_rate
  end
  def self.transferred_up
    -23
  end
  def self.transferred_down
    -42
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
    %w(torrent_dir).
      inject({}) { |hsh,dir| hsh.merge({ dir => Torrent.diskfree(Settings[dir]) }) }
  end


  # extended attributes
  def progress
    (100.0 * completed_bytes.to_f / content_size.to_f).to_i
  rescue FloatDomainError
    0
  end
  def bytes_left
    content_size - completed_bytes
  end
  def eta
    bytes_left.to_f / down_rate.to_f
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

  def calculate_info_hash
    return unless metainfo
    metainfo.sha1.unpack('H*').first.upcase
  end

  def info_hash
    self[:info_hash] ||= calculate_info_hash
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
    return "bad status: #{status}" unless filepath_by_status(wanted_state)
    filepath_by_status(wanted_state)
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
      (filename.blank? ? "Torrent ##{id}" : clean_filename)
  end
  # synonym for short_title
  def nice_title
    short_title
  end

  def clean_filename
    filename.
      gsub(/(?:dvd|xvid|divx|hdtv|cam\b)/i,'').
      gsub(/\[.*?\]/,'').
      gsub(/\(.*?\)/,'').
      sub(/\d{5,}.TPB/,'').
      sub(/\.?torrent$/i,'').
      gsub(/[._-]+/,' ').
      gsub(/\s{2,}/,' ').
      rstrip.lstrip
  end

  def file_exists?(stat=self.current_state)
    if self.filename
      unless (path = fullpath(stat.to_sym)).blank?
        return File.exists?(path)
      end
    end
    false
  end

  def auto_set_status
    self.status= 
      unless file_exists?
        unless url.blank?
          :remote
        else
          status_by_filepath
        end
      else
        status
      end
  end

  def before_destroy
    stop! if valid? and running?
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
    calculate_info_hash
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

  # Here lies the content while it is being downloaded (default)
  def working_path
    return '' unless metainfo
    File.join(Settings.torrent_dir,metainfo.name)
  end

  # where to find the contents, either saved :content_path or #working_path
  def content_path
    self[:content_path] ||= working_path
  end

  # returns the current url to the content for the user
  # the user has to specify his moutpoints for that to happen
  def content_url(usr)
    return nil # FIXME we have no target_dir anymore
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

  def fetchable?(please_reload=false)
    unless @fetchable.nil? || please_reload
      return @fetchable
    end
    @fetchable =
      begin
        Net::HTTP.start(uri.host, uri.port) do |http|
          resp = http.head(uri.path)
          if resp.is_a?(Net::HTTPSuccess) and (resp['content-type'] =~ /application\/x-bittorrent/i)
            self.filename = filename_from_http_response(resp)
            resp
          else
            errors.add :url, "HTTP Error: #{resp.inspect}, Content-type: #{resp['content-type']}"
            false
          end
        end
      rescue URI::InvalidURIError
        errors.add :url, "is not valid (#{url.to_s})"
        false
      rescue SocketError, NoMethodError => e
        errors.add :url, "unfetchable (#{e.to_s})"
        false
      end
  end

  def fetch_by_url
    if resp = Net::HTTP::get_response(uri) and resp.is_a?(Net::HTTPSuccess)
      unless filename
        update_attribute :filename, filename_from_http_response(resp)
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


  def move_content_to new_path
    begin
      # TODO
      # content must be at #content_path
      # the target should exist, but should not contain #metainfo.name ?
      # change content_path
    rescue Exception => e
      errors.add :filename, "^error on moving content: #{e.to_s}"
    end
  end

  def delete_content!
    return unless metainfo
    begin
      opfer = content_path
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

  def moveto(target,opts={})
    source = fullpath
    target = fullpath(target) if target.is_a?(Symbol)
    return if source.blank?
    return if target.blank?
    return unless File.exists? source
    begin
      if opts[:copy]
        copy(source,target)
      else
        move(source,target)
      end
    #rescue Exception => e
    #  errors.add :filename, "^error while moving torrent: #{e.to_s}"
    end
  end

  # make sure that a copy of this torrent is in the archive
  def assure_file_in_archive!
    if file_exists?
      moveto( :archived, :copy => true) unless file_exists?(:archived)
    elsif !(real_path = remote.tied_to_file).blank?
      copy( real_path, fullpath(:archived) ) unless file_exists?(:archived)
      copy( real_path, fullpath )
    elsif !(real_path = find_file).blank?
      copy( real_path, fullpath(:archived) ) unless file_exists?(:archived)
      copy( real_path, fullpath )
    end
  rescue TorrentNotRunning, TorrentHasNoInfoHash
    false
  rescue Exception => e
    errors.add :filename, "^error while assure_file_in_archive: #{e.to_s}"
    false
  end

  def sync
    sync! if needs_to_be_synced?
  end

  def sync!
    set_metainfo && synced_at = Time.now
  end


  SYNC_INTERVAL = 1.day unless defined? SYNC_INTERVAL
  def needs_to_be_synced?
    synched_at.blank? || (Time.now - synched_at > SYNC_INTERVAL)
  end

  # checks all torrents in database
  #  * exists the file?
  #  * reads the hash if it is not already in the db
  #  * ..
  def self.sync
    recognize_new
    find_all_outdated.each do |t|
      t.sync!
      unless t.valid?
        # FIXME beware!! check validations first
        #t.destroy
        logger.info "Torrent ##{t.id} seems to be invalid. We will destroy them! (Worf, 237x)"
      else
        t.save
      end
    end
  end
  def self.find_all_outdated
    find(:all, 
         :conditions => ['synched_at IS NULL OR synched_at < ?', Time.now - SYNC_INTERVAL]
        )
  end

  # looks in the torrent_dir for new torrent files and creates them
  def self.recognize_new
    created = []
    Dir[File.join(Settings.torrent_dir,'*.torrent')].each do |filepath|
      filename = File.basename filepath
      torrent = new(:filename => filename, :status => 'new')
      torrent.moveto(:archived)
      if torrent.save
        created << torrent 
        torrent.start!
      end
    end
    return created
  end

  # Looks into rtorrent's download_list and adds the running torrents to the db
  # unless they exist already
  # FIXME: what if somebody adds a torrent somewhere on the filesystem?
  # FIXME: rtorrent does not give us the torrent's filename, just the name of hte directory
  # => gggrml!
  def self.recognize_running
    saved = []
    hashes = rtorrent.download_list
    hashes.each do |hash|
      if torrent = find_by_info_hash(hash)
        torrent.filename ||= torrent.remote.base_filename + '.torrent'
        torrent.status = torrent.status_from_rtorrent unless torrent.status =~ /^running|paused$/
      else
        torrent = new(:info_hash => hash)
        torrent.status = torrent.status_from_rtorrent
        torrent.filename = torrent.remote.base_filename + '.torrent'
      end
      torrent.assure_file_in_archive!
      torrent.moveto(:running,:copy => true)
      if torrent.save
        saved << torrent
      end
    end
    saved
  end

 private
  def filepath_by_status(stat)
    case stat.to_sym
    when :fetching 
      File.join(Settings.history_dir, filename) + '.fetching'
    when :running  
      File.join(Settings.torrent_dir, 'active', filename)
    when :paused   
      File.join(Settings.torrent_dir, 'active', filename)
    when :new      
      File.join(Settings.torrent_dir, filename)
    when :archived 
      File.join(Settings.history_dir, filename)
    when :remote   
      ''
    else
      nil
    end
  end

  def status_by_filepath
    STATES.find(:invalid) do |stat|
      path = filepath_by_status(stat)
      path.blank? || File.exists?(path)
    end
  rescue NoMethodError
    return :invalid
  end

  def find_file
    STATES.map {|s| filepath_by_status(s) }.find { |p| File.exists?(p) }
  end

  # removes the leading './' or path from the filename
  # and adds the .torrent extension
  def fix_filename
    unless self.filename.blank?
      self.filename.sub!(/^.*\/([^\/]*)$/, '\1')
      self.filename += '.torrent' unless self.filename =~ /\.torrent$/
    end
  end

  def set_default_values
    self.status ||= 'running'
    self.content_size      ||= 0
    self.description     ||= ''
  end

  # checks is the torrent was just finished downloading 
  # and notifies all subscripted users if this is the case
  def notify_if_just_finished
    return # disabled for now
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
      begin
        yield
      rescue TorrentNotRunning
        finally_stop!
      rescue TorrentHasNoInfoHash
        update_attribute(:status,:invalid)
        reload
      end
    else
      raise RuntimeError, "#{current_state} is not a valid state for this transition"
    end
  end

  # Will try to get status from rtorrent and stop the torrent
  # if it's not open/active (in case) of and rtorrent restart etc.
  def check_if_status_is_up_to_date
    good = case current_state
           when :running
             remote.active?
           when :paused
             remote.open?
           else 
             true
           end
    return good
  rescue TorrentNotRunning, TorrentHasNoInfoHash 
    finally_stop!           # hmm
    reload
  end

  private

  def filename_from_http_response(resp)
    fn = if cdis = resp['content-disposition']
           cdis.sub(/^.*filename=(.+)$/,'\1').
                sub(/^"+/, '').
                sub(/"+$/, '')
         elsif !self.url.blank?
           self.url.sub(/.*\//,'')
         else
           %Q[downloaded-torrent-#{self.id}]
         end
    fn += '.torrent' unless fn =~ /\.torrent$/
    fn
  end


end
