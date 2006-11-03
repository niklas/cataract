require 'uri'
class RSS::Rss::Channel::Item
end
class Feed < ActiveRecord::Base
  has_many :torrents, :dependent => :nullify
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
    items.each do |item|
      enclosure = item.enclosure
      next unless enclosure
      next unless enclosure.type == 'application/x-bittorrent'
      next if item.title and Torrent.find_by_title(item.title)
      next if item.description and Torrent.find_by_title(item.description)
      title = item.title || item.description
      next unless title
      next if Torrent.find_by_url(enclosure.url)
      torrents.create(:url => enclosure.url, :title => title, :status => 'remote')
    end
    outdated_torrents.each { |t| t.destroy }
    update_attribute :synced_at, Time.now
  end

  def outdated_torrents
    torrents.find(:all, 
                  :order => 'created_at desc', 
                  :offset => item_limit,
                  :limit => item_limit * 10, 
                  :conditions => ['status = ?','remote']
                 )
  end

  def parse(data=nil)
    @parsed ||= if data
      RSS::Parser.parse(data)
    else
      RSS::Parser.parse(open(self.url) { |fd| fd.read })
    end
  end

  def filter_regexp
    Regexp.new /#{tags.collect(&:expression).join('|')}/i
  end

  private
  def set_url_as_title
    self.title = self.url if !self.title or self.title.empty?
  end
end
