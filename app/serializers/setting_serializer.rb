class SettingSerializer < BaseSerializer
  include ActionView::Helpers::TagHelper
  attributes :disable_signup
  has_one :incoming_directory

  def attributes
    super.tap do |hash|
      hash['id'] = 'all'
      hash['bookmark_link'] = link_to_bookmarklet "Bookmarklet", new_scraping_url(format: 'js')
    end
  end

  def link_to_bookmarklet(title, url, link_opts={})
    raise "url must be absolute" unless url.starts_with?('http')
    opts = {
      error_message: link_opts.delete(:error_message) || "Could not reach #{url}",
      token: current_user.remember_token
    }
    js = RailsBookmarklet::compile_invocation_script(url, opts)
    content_tag :a, title, opts.merge(href: js)
  end
end
