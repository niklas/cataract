# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def settings
    @settings ||= Setting.singleton
  end

  def link_to_bookmarklet(title, url, link_opts={})
    raise "url must be absolute" unless url.starts_with?('http')
    opts = {
      error_message: link_opts.delete(:error_message) || "Could not reach #{url}",
      token: current_user.remember_token
    }
    js = RailsBookmarklet::compile_invocation_script(url, opts)
    link_to title, js, opts
  end
end
