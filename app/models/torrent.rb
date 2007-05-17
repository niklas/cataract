require 'ftools'
require 'fileutils_monkeypatch'
require 'rubytorrent'
require 'net/http'
require 'uri'
require_dependency 'search'
class Torrent < ActiveRecord::Base
  include FileUtils
  has_many :watchings, :dependent => true
  has_many :users, :through => :watchings
  belongs_to :feed
  validates_uniqueness_of :filename, :if => Proc.new { |torrent| !torrent.remote? }
#  validates_presence_of :filename
  validates_format_of :url, :with => URI.regexp, :if => Proc.new {|torrent| torrent.remote? }

  before_update :notify_if_just_finished
  before_save :sync
  after_create :notify_users_and_add_it
  before_create :set_default_values

  searches_on :title, :filename, :url

  acts_as_taggable
  acts_as_state_machine :initial => :running, :column => :status

  state :paused, :enter => Proc.new { |t| 
    t.moveto(t.fullpath(:paused))
    t.brake
  }
  state :stopping, :enter => Proc.new { |t| 
    t.moveto(t.fullpath(:stopping))
    t.archive!
  }
  state :archived, :enter => Proc.new { |t| 
    t.archive_content
    t.moveto(t.fullpath(:archived))
  }
  state :running, :enter => Proc.new { |t|
    t.unarchive_content
    t.moveto(t.fullpath(:running))
  }
  state :fetching, :enter => Proc.new { |t|
    t.fetch_by_url
  }
  state :remote

  event :pause do
    transitions :from => [:running], :to => :paused
  end
  event :start do
    transitions :from => [:paused, :archived, :fetching], :to => :running
  end
  event :archive do
    transitions :from => [:stopping], :to => :archived
  end
  event :stop do
    transitions :from => [:paused,:running], :to => :stopping
  end
  event :fetch do
    transitions :from => :remote, :to => :fetching
  end

  def fetch_and_start!
    fetch!
    start!
  end

  def self.invalid
    condition = 'NOT (' + self.class.states.collect { |s| "(status='#{s.to_s}')"}.join(' OR ') + ')'
    find(:all, :conditions => condition, :order => 'created_at')
  end

  def self.running
    find_in_state(:all, :running, :order => 'created_at desc')
  end

  def self.find_collection(ids)
    return [] unless ids
    return [] if ids.empty?
    find_all_by_id(ids)
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
  def self.diskfree
    dir = Settings.torrent_dir
    cmd = '/bin/df'
    if File.exists?(dir) and File.exists?(cmd)
      `#{cmd} '#{dir}'`.split[10].to_i
    else
      0
    end
  end


  # extended attributes
  def percent
    percent_done
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
  def short_title
    title ||
    filename.
      gsub(/(?:dvd|xvid|divx|hdtv|cam\b)/i,'').
      gsub(/\[.*?\]/,'').
      gsub(/\(.*?\)/,'').
      sub(/\d{5,}.TPB/,'').
      sub(/\.?torrent$/i,'').
      gsub(/[._-]+/,' ').
      gsub(/\s{2,}/,' ').rstrip.lstrip
  end
  # synonym for short_title
  def nice_title
    short_title
  end

  def file_exists?
    File.exists?(fullpath)
  end

  # set rates to 0
  def brake
    self.rate_up = 0
    self.rate_down = 0
  end

  def validate
    if !remote? and !File.exists?(fullpath)
      validate_file_status
    else
      true
    end
  end

  def before_destroy
    File.delete(fullpath) if validate_file_status
  end

  def files_hierarchy
    return {} unless metainfo
    return {metainfo.name => ''} if metainfo.single?
    return {} unless metainfo.files
    metainfo.files.
      map      { |file| file.path }.
      group_by { |path| path.first }
  end

  def before_validation
    fix_filename
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
  def content_path
    return '' unless metainfo
    File.join(Settings.torrent_dir,metainfo.name)
  end

  # When a torrent is archived, the content will be moved here
  def target_path
    return '' unless metainfo
    File.join(Settings.target_dir,metainfo.name)
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
      @mii ||= RubyTorrent::MetaInfo.from_location(fullpath).info
    rescue # RubyTorrent::MetaInfoFormatError
      # no UDP supprt yet
      @mii = nil
    end
  end
  
  def fetchable?
    uri = URI.parse(url)
    resp = Net::HTTP.get_response(uri)
    if resp.is_a?(Net::HTTPSuccess) and resp.content_type == "application/x-bittorrent"
      return resp
    else
      errors.add :url, "Code: #{resp.code}, Content-type: #{resp['content-type']}"
      return false
    end
  rescue URI::InvalidURIError
    errors.add :url, "is not valid (#{uri.to_s})"
    return false
  rescue NoMethodError,SocketError
    errors.add :url, "is invalid (#{uri.to_s})"
    return false
  end

  def fetch_by_url
    if resp = fetchable?
      unless self.filename
        if cdis = resp['content-disposition']
          self.filename = cdis.sub(/^.*filename=(.+)$/,'\1')
          self.filename.sub! /^"+/, ''
          self.filename.sub! /"+$/, ''
        else
          self.filename = self.url.sub(/.*\//,'')
        end
        self.filename += '.torrent' unless self.filename =~ /\.torrent$/
      end
      File.open(fullpath(:fetching), 'w') do |file|
        file.write resp.body
      end
      self.save
      return self
    else
      return false
    end
  end

  def archive_content
    return unless metainfo
    begin
      move(content_path,target_path) if File.exists?(content_path)
    rescue Exception => e
      errors.add :filename, "^error on moving content: #{e.to_s}"
    end
  end

  def unarchive_content
    return unless metainfo
    begin
      move(target_path,content_path) if File.exists?(target_path)
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
                content_path
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
    return unless source
    return unless target
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

  def validate_file_status
    return true if remote?
    filepath_status.each do |s,p|
      if File.exists?(p) 
        write_attribute(:status, s)
        return true
      end
    end
    return false
  end

  # removes the leading './' or path from the filename
  def fix_filename
    filename.sub!(/^.*\/([^\/]*)$/,'\1') if filename
  end

  def set_default_values
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
end
