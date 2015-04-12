class ParseRSS
  include Interactor

  def call
    if rss = context.http_response
      context.abstract_feed = FeedAbstract::Feed.new(rss)
    else
      context.fail! message: 'no http_response found in context'
    end
  rescue RSS::Error => e
    context.fail! message: "Could not parse RSS: #{e.inspect}"
  end
end
