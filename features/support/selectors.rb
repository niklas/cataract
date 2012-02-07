module HtmlSelectorsHelpers
  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  def selector_for(locator)
    case locator

    when "the page"
      "html > body"
    when "current user"
      "#session .name"

    when "the header"
      "div[data-role='header']"
    when "the footer"
      "div[data-role='footer']"

    # TODO move to jquery_mobile
    when /^flash (notice|alert)$/
      "#flash .#{$1}"

    when 'the content'
      ".content"
    when 'the progress'
      ".progress"
    when /^the (up|down) rate$/
      ".#{$1}"
    when /^the transfer of #{capture_model}$/
      "#transfer_torrent_#{model!($1).id}"

    when 'the page title'
      "h1.title:last"

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #  when /^the (notice|error|info) flash$/
    #    ".flash.#{$1}"

    # You can also return an array to use a different selector
    # type, like:
    #
    #  when /the header/
    #    [:xpath, "//header"]

    # This allows you to provide a quoted selector as the scope
    # for "within" steps as was previously the default for the
    # web steps:
    when /^"(.+)"$/
      $1

    else
      raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
