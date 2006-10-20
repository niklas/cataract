require 'ftools'
require 'rubytorrent'
require 'net/http'
require 'uri'
class Torrent < ActiveRecord::Base
  has_many :watchings, :dependent => true
  has_many :users, :through => :watchings
  validates_uniqueness_of :filename
  validates_presence_of :filename

  before_update :notify_if_just_finished
  after_create :notify_users_and_add_it
  before_create :set_default_values

  VALID_STATI=%w(paused archived running)

  # Groups by status
  def self.running
    find_all_by_status('running', :order => 'created_at')
  end

  def self.archived
    find_all_by_status('archived', :order => 'created_at')
  end

  def self.paused
    find_all_by_status('paused', :order => 'created_at')
  end

  def self.invalid_status
    condition = 'NOT (' + VALID_STATI.collect { |s| "(status='#{s}')"}.join(' OR ') + ')'
    find(:all, :conditions => condition, :order => 'created_at')
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

  def fullpath
    filepath_status[status] || ''
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

  # download actions
  def pause
    self.status='paused'
  end

  def start
    unarchive_content
    self.status='running'
  end

  def archive
    self.status='archived'
    archive_content
  end

  # set rates to 0
  def brake
    self.rate_up = 0
    self.rate_down = 0
  end

  def status=(new_status)
    raise "illegal status #{new_status}" unless VALID_STATI.include?(new_status)
    moveto(filepath_status[new_status])
    write_attribute(:status, new_status) unless errors.on :filename
  end

  def validate
    unless File.exists?(fullpath)
      validate_file_status
    end
  end

  def files
    @files ||= 
      if metainfo.single?
        [metainfo.name]
      else
        metainfo.files.map { |f| File.join(metainfo.name, f.path)}
      end
  end

  def before_validation
    fix_filename
  end

  def store_metainfo
    if metainfo.single?
      self.size = metainfo.length
    else
      self.size = metainfo.files.inject(0) { |sum, f| sum + f.length}
    end
    save
  end

  # Here lies the content while it is being downloaded
  def content_path
    File.join(Settings.torrent_dir,metainfo.name)
  end

  # When a torrent is archived, the content will be moved here
  def target_path
    File.join(Settings.target_dir,metainfo.name)
  end

  def finished?
    percent == 100 and statusmsg == 'seeding'
  end

  def running?
    statusmsg =~ /^[\d:]+$/ or (rate_down and rate_up and rate_down + rate_up > 0)
  end

  def available?
    peers >= 1 or distributed_copies >= 1
  end
  
  #private
  def filepath_status
    {
      'archived' => File.join(Settings.history_dir, filename),
      'paused'   => File.join(Settings.torrent_dir, filename) + '.paused',
      'running'  => File.join(Settings.torrent_dir, filename)
    }
  end

  def validate_file_status
    st = 'missing' # fallback
    filepath_status.each do |s,p|
      st = s if File.exists?(p)
    end
    write_attribute(:status, st)
  end

  # removes the leading './' or path from the filename
  def fix_filename
    filename.sub!(/^.*\/([^\/]*)$/,'\1')
  end

  def set_default_values
    self.size      ||= 0
    self.rate_down ||= 0
    self.rate_up   ||= 0
    self.seeds     ||= 0
    self.peers     ||= 0
    self.description     ||= ''
    self.percent_done    ||= 0
    self.transferred_up   ||= 0
    self.transferred_down ||= 0
  end

  def moveto(target)
    source = fullpath
    begin
      File.move(source,target)
    rescue SystemCallError => e
      errors.add :filename, "^error on moving torrent: #{e.to_s}"
    end
  end

  def metainfo
    begin
      @mii ||= RubyTorrent::MetaInfo.from_location(fullpath).info
    rescue RubyTorrent::MetaInfoFormatError
      # no UDP supprt yet
      @mii = nil
    end
  end

  def archive_content
    begin
      File.move(content_path,target_path)
    rescue SystemCallError => e
      errors.add :filename, "^error on moving content: #{e.to_s}"
    end
  end

  def unarchive_content
    begin
      File.move(target_path,content_path)
    rescue SystemCallError => e
      errors.add :filename, "^error on moving content: #{e.to_s}"
    end
  end

  # methods for external fetching
  def fetchable?
    uri = URI.parse(url)
    resp = Net::HTTP.get_response(uri)
    if resp.is_a?(Net::HTTPSuccess) and resp['content-type'] =~ /torrent/
      return true
    else
      errors.add :url, "Code: #{resp.code}, Content-type: #{resp['content-type']}"
      return false
    end
  rescue URI::InvalidURIError,NoMethodError,SocketError
    errors.add :url, 'is not valid'
    return false
  end

  attr_accessor :url
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
    User.find_all_by_notify_on_new_torrents(true).each do |user|
      Notifier.send_new(user,self) if user.notifiable_via_jabber?
      user.watch(self)
    end
  end
end
