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

    when /^the (menu|header)$/
      "div.navbar"

    when /^the disks? list$/
      "ul.disks"

    when /^the director(y|ies) list$/
      "table.directories"

    when "the footer"
      raise "no footer"
      "div[data-role='footer']"

    when 'the spinner'
      '#spinner'

    when 'the modal box'
      'div.modal'

    when /^(\w+) link$/
      "a.#{$1}"

    # TODO move to jquery_mobile
    when /^(?:a )?flash (notice|alert)$/
      "#flash .alert-#{$1}"

    when 'the content'
      ".content"

    when /^the (\w+) section$/
      "section.#{$1}"
    when /the progress( pie)?/
      ".progress-pie"
    when /^the (up|down) rate$/
      ".#{$1}"
    when /^the transfer of #{capture_model}$/
      "#transfer_torrent_#{model!($1).id}"

    when 'the window title'
      "title"

    when 'the page title'
      "h1#title"

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
