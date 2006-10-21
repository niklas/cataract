require 'uri'
class Feed < ActiveRecord::Base
  has_many :filters
  validates_presence_of :url, :message => "URL is needed"
  validates_format_of :url, :with => URI.regexp
  validates_presence_of :title, :message => "please give a title"

  before_validation :set_url_as_title

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
    %w(Foo Bar Baz)
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
    self.title = self.url if !self.title or self.title.empty?
  end
end
