module HtmlSelectorsHelpers
  Numerals = {
    'first'  => ':first',
    'second' => ':nth-of-type(2)',
    'third'  => ':nth-of-type(3)',
    'forth'  => ':nth-of-type(4)'
  }

  def capture_nth
    /(#{Numerals.keys.join('|')})/
  end
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

    when /^the sidebar disks? list$/
      "#sidebar ul.disks"

    when /^the sidebar director(?:ies|y) list$/
      "#sidebar ul.directories"

    when /^the torrents? list$/
      "ul#torrents"

    when /^the #{capture_nth} (torrent)$/
      selector_for("the #{$2.pluralize} list") + " li#{Numerals[$1]}"

    when /^the director(y|ies) list$/
      "table.directories"

    when "the footer"
      raise "no footer"
      "div[data-role='footer']"

    when 'the spinner'
      '#spinner > .spinner'

    when 'the modal box'
      'div.modal'

    when 'the queue'
      '#queue'

    when 'the breadcrumbs'
      'ul.breadcrumb'

    when 'the sidebar'
      '#sidebar'

    when 'a row'
      '.row-fluid'

    when /^(?:the )?item of #{capture_model}$/
      "##{ model!($1).decorate.item_id }"

    when /^the (\w+) link$/
      "a.#{$1}"

    # TODO move to jquery_mobile
    when /^(?:a )?flash (notice|alert)$/
      ".flash.alert-#{$1}"

    when 'the content'
      "#content"

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
