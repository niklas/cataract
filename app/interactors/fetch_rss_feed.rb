class FetchRSSFeed
  include Interactor
  include InteractorLoggable

  def call
    feed = context.feed

    if feed && feed.present? && feed.url.present?
      case response = fetch(feed.url)
      when Net::HTTPSuccess
        context.http_response = response.body
      else
        context.fail! message: "Could not fetch: #{response}"
      end
    else
      context.fail! message: 'need Feed with url'
    end
  end

  private

  # fetch from <url> with a maximum <limit> of following redirect
  def fetch(url, limit=5)
    url = URI.parse(url) unless url.is_a?(URI)
    debug { "#{self.class} fetching #{url}" }
    case response = Net::HTTP::get_response(url)
    when Net::HTTPRedirection
      if limit > 0
        new_url = response['location']
        debug { "#{self.class} following redirect to #{new_url}" }
        fetch new_url, limit - 1
      else
        context.fail! message: "unfetchable: redirect loop"
        response
      end
    when Net::HTTPSuccess
      debug { "#{self.class} fetched #{response.inspect}" }
      response
    else
      context.fail! "unfetchable: #{response.inspect}"
      response
    end
  rescue URI::InvalidURIError
    # often there are special chars (unescaped) in the filename
    escaped = url.sub(%r~(?<=/)[^/]+$~) { |m| CGI.escape(m) }
    fetch escaped, limit
  rescue SocketError, Errno::ECONNREFUSED, NoMethodError => e
    context.fail! message: "unfetchable: #{e}"
    false
  end
end
