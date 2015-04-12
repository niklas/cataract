class FetchRSSFeed
  include Interactor

  def call
    feed = context.feed

    if feed && feed.present? && feed.url.present?
      context.http_response = fetch(feed.url)
    else
      context.fail! message: 'need Feed with url'
    end
  end

  private

  def fetch(url)
    uri = URI.parse(url)
    Net::HTTP::get_response(uri).body
  end
end
