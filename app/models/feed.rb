class Feed < ActiveRecord::Base
  validates_presence_of :url
  validates_format_of :url, :with => URI.regexp
  validates_presence_of :title

  before_validation :set_url_as_title

  # TODO use FetchRSSFeed
  def items
    parsed.items
  end

  protected

  def parsed_url
    URI.parse(url)
  end

  def parsed
    @parsed ||= FeedAbstract::Feed.new(fetched)
  end

  def fetched
    Net::HTTP::get(parsed_url)
  end

  private
  def set_url_as_title
    self.title = self.url if self.title.blank?
  end
end
