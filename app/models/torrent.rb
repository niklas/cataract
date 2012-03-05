# == Schema Information
# Schema version: 36
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
#

class Torrent < ActiveRecord::Base
  include FileUtils
  has_many :watchings, :dependent => :destroy
  has_many :users, :through => :watchings
  belongs_to :feed # TODO remove when series assigned
  belongs_to :series
  
  validates_format_of :url, :with => URI.regexp, :if => :remote?

  concerned_with :refresh # callbacks required, so more at end of file

  # FIXME remove this insane stati code
  # before_save :sync
  # before_validation :fix_filename
  # before_validation :sync_status!
  # FIXME wtf is this?
  #stampable

  def after_find
    check_if_status_is_up_to_date
  end

  def before_destroy
    stop! if running?
  end

  def to_s
    "#{self.class} (#{id}) '#{title}' [#{filename}]"
  end

  def self.temporary_predicate(name)
    attr_accessor name
    define_method :"#{name}?" do
      send(name).present?
    end
  end

  # TODO add tagging
  # acts_as_taggable

  scope :invalid, where('NOT (' + Torrent::STATES.collect { |s| "(status='#{s.to_s}')"}.join(' OR ') + ')')

  scope :include_everything, includes(:tags)

  def self.watched_by(user)
    includes(:watchings).where('watchings.user_id = ?', user.id)
  end


  # TODO use psql tsearch
  # has_fulltext_search :title, :description, :filename, :url, 'tags.name'

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

  # extended attributes

  def seconds_left
    left_bytes.to_f / down_rate.to_f
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

  def actual_size
    content_size * percent / 100
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
  def title
    super.presence ||
      (filename.blank? ? "Torrent ##{id}" : clean_filename)
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


  def before_destroy
    stop! if valid? and running?
    File.delete(fullpath) if file_exists?
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


  # removes the leading './' or path from the filename
  # and adds the .torrent extension
  def fix_filename
    unless self.filename.blank?
      self.filename.sub!(/^.*\/([^\/]*)$/, '\1')
      self.filename += '.torrent' unless self.filename =~ /\.torrent$/
    end
  end

  def log(action,level=:info,culprit = (self.updater|| self.creator))
    LogEntry.create(
      :loggable => self,
      :user => culprit,
      :action => action,
      :level => level.to_s
    )
  end

  # TODO audit changes
  def log(*)
    Rails.logger.debug "disabled own logging"
  end

  concerned_with :states,
                 :remote,
                 :file,
                 :rtorrent,
                 :transfer,
                 :content,
                 :search

end

# just mention this here to kick off preloading
TorrentDecorator
