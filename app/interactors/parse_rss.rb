class ParseRSS
  include Interactor

  def call
    if context.http_response
      context.abstract_feed = FeedAbstract::Feed.new(context.http_response)
    else
      context.fail! message: 'no http_response found in context'
    end
  end
end
