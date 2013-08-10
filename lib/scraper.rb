class Scraper
  def self.scrape(url)
    new(url).scrape
  end

  attr_reader :messages

  def initialize(url)
    @url = url
    @messages = []
  end

  def scrape
    @messages << 'Starting scrape'
    self
  end

  def success?
    true
  end
end
