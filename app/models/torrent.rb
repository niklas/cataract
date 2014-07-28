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

require 'cataract/file_name_cleaner'

class Torrent < ActiveRecord::Base
  has_many :watchings, :dependent => :destroy
  has_many :users, :through => :watchings
  belongs_to :feed # TODO remove when series assigned
  belongs_to :series
  
  validates_format_of :url, :with => URI.regexp, :if => :remote?

  concerned_with :refresh # callbacks required, so more at end of file
  attr_protected # allow all

  # FIXME remove this insane stati code
  # before_save :sync
  before_validation :fix_filename
  # before_validation :sync_status!
  # FIXME wtf is this?
  #stampable

  def self.recent
    order 'updated_at DESC, created_at DESC'
  end

  def self.since(date)
    where 'updated_at > ?', date
  end

  def self.aged(n)
    case n
    when 'month'
      since 1.month.ago
    when /^month(\d+)$/
      since $i.to_i.months.ago
    when 'year'
      since 1.year.ago
    else
      all
    end
  end

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

  scope :invalid, -> { where('NOT (' + Torrent::STATES.collect { |s| "(status='#{s.to_s}')"}.join(' OR ') + ')') }

  scope :include_everything, -> { includes(:tags) }

  def self.watched_by(user)
    includes(:watchings).where('watchings.user_id = ?', user.id)
  end


  # TODO use psql tsearch
  # has_fulltext_search :title, :description, :filename, :url, 'tags.name'

  def self.last_update
    Torrent.maximum('updated_at', :conditions => "status = 'running'") || 23.days.ago
  end

  # extended attributes

  def actual_size
    content_size * percent / 100
  end

  def title
    super.presence || Cataract.title_finder[self]
  end

  def clean_filename
    Cataract.debrander[filename]
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
  def log(*a)
    Rails.logger.debug { a }
  end

  concerned_with :states,
                 :remote,
                 :file,
                 :rtorrent,
                 :transfer,
                 :payload,
                 :search

end
