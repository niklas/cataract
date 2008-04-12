# == Schema Information
# Schema version: 35
#
# Table name: feeds
#
#  id         :integer       not null, primary key
#  url        :string(2048)  
#  title      :string(255)   
#  user_id    :integer       
#  created_at :datetime      
#  fetched_at :datetime      
#  synced_at  :datetime      
#  item_limit :integer       default(100)
#

require 'uri'
require 'rss/0.9'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/parser'

class RSS::Rss::Channel::Item
  def title_or_description
    title || description
  end
end
class Feed < ActiveRecord::Base
  has_many :torrents, :dependent => :nullify do
    def outdated
      find(:all, 
           :order => 'created_at desc', 
           :offset => proxy_owner.item_limit,
           :limit => proxy_owner.item_limit * 10, 
           :conditions => ['status = ?','remote']
          )
    end
  end
  has_many :filters, :order => 'position'
  validates_presence_of :url, :message => "URL is needed"
  validates_format_of :url, :with => URI.regexp
  validates_presence_of :title, :message => "please give a title"

  before_validation :set_url_as_title

  acts_as_taggable

  def fetchable?
    return false unless valid?
    uri = URI.parse(url)
    resp = Net::HTTP.get_response(uri)
    if resp.is_a?(Net::HTTPSuccess) and resp.content_type =~ /^text\/xml|application\/rss\+xml$/
      self.title = self.parse(resp.body).channel.title
      return resp
    else
      errors.add :url, "Code: #{resp.code}, Content-type: #{resp['content-type']}"
      return false
    end
  rescue URI::InvalidURIError
    errors.add :url, "is not valid (#{uri.to_s})"
    return false
  rescue NoMethodError,SocketError => e
    errors.add :url, "is invalid (#{e.to_s})"
    return false
  end

  def items
    parse.channel.items
  end

  def sync(force=false)
    return if !force and synced_at and Time.now.ago(23.minutes) < synced_at
    new_torrents = []
    items.each do |item|
      enclosure = item.enclosure
      next unless enclosure
      next unless enclosure.type == 'application/x-bittorrent'
      next if item.title and Torrent.find_by_title(item.title)
      next if item.description and Torrent.find_by_title(item.description)
      title = item.title_or_description
      next unless title
      next if Torrent.find_by_url(enclosure.url)
      new_torrents << torrents.create(:url => enclosure.url, :title => title, :status => 'remote')
    end
    torrents.outdated.each { |t| t.destroy }
    filtered(new_torrents).each { |t| t.start! }
    update_attribute :synced_at, Time.now
  end

  def self.sync(force=false)
    num = 0
    find(:all).each { |feed| num += 1 if feed.sync(force) }
    num
  end

  def filtered_torrents(reload=false)
    @filtered_torrents = nil if reload
    @filtered_torrents ||= filtered(torrents)
  end

  def filtered_items(reload=false)
    @filtered_items = nil if reload
    @filtered_items ||= filtered(items)
  end

  protected
  # filters items or torrents
  #  * items must match at least one positive filter
  #  * but may not match any negated filter
  def filtered(given=[])
    return [] if given.empty?
    return items if filters.empty?

    # reload the filters (once)
    filters.positive(true)
    filters.negated(true)

    wanted = []
    given.each do |item|
      term = item.title || item.title_or_description
      filters.positive.each do |filter|
        if filter.matches? term
          wanted << item # this is what we want, take it (for now)
          break
        end
      end
    end

    wanted.each do |item|
      term = item.title || item.title_or_description
      filters.negated.each do |filter|
        if filter.matches? term # we don't want that, throw away
          wanted.delete item
          break
        end
      end
    end

    wanted
  end

  def parse(data=nil)
    @parsed ||= if data
      RSS::Parser.parse(data)
    else
      RSS::Parser.parse(open(self.url) { |fd| fd.read })
    end
  end

  private
  def set_url_as_title
    self.title = self.url if self.title.blank?
  end
end
