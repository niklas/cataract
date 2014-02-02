module BookmarkletHelper
  def link_to_scrape_bookmarklet(title="Bookmarklet", opts={})
    link_to_bookmarklet title, open_scraping_url(format: 'js'), opts
  end

  def link_to_bookmarklet(title, url, link_opts={})
    js = script_for_bookmarklet url, link_opts.delete(:error_message)
    content_tag :a, title, link_opts.merge(href: js)
  end

  def script_for_bookmarklet(url, error_message=nil, opts={})
    #raise "url must be absolute" unless url.starts_with?('http')
    field = opts.delete(:location_attribute) { 'location' }
    opts = {
      error_message: error_message.presence || "Could not reach #{url}",
      params: {
        "url" => "'+encodeURI(d.#{field})+'"
      }
    }
    RailsBookmarklet::compile_invocation_script(url, opts)
  end
end

