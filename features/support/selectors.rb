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

    when /^the sidebar disks? list$/
      "#sidebar ul.disks:first"

    when /^the sidebar director(?:ies|y) list$/
      "#sidebar > .well > ul.directories"

    when /^the detail bar$/
      '#bar'

    when /^the disks tab$/
      '.nav-tabs.disks'

    when /^the torrents? list$/
      "ul#torrents"

    when /^a torrents? list$/
      "ul.torrents"

    when /^the #{capture_nth} (torrent)$/
      css2xpath selector_for("the #{$2.pluralize} list") + "> li#{Numerals[$1]}"

    when /^the #{capture_nth} of the (.*)$/
      nth = $1
      sel = (['ul'] + $2.split(' ')).join('.')
      "#{sel} > li#{Numerals[nth]}"

    when /^the #{capture_nth} row$/
      css2xpath "tr#{Numerals[$1]}"

    when /^the director(y|ies) list$/
      "ul.directories"

    when /^the (\w+s) table$/
      "table.#{$1}"

    when /^the (\w+) title$/
      "##{$1} h2.title"

    when "the footer"
      raise "no footer"
      "div[data-role='footer']"

    when 'the spinner'
      '.spinner'

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

    when 'a label'
      'span.label' # bootstrap

    when /^(?:the )?item of #{capture_model}$/
      "##{ model!($1).decorate.item_id }"

    when /^the (\w+) (?:link|button)$/
      "button.#{$1}"

    when /^the active nav item$/
      'ul.nav > li.active'

    # TODO move to jquery_mobile
    when /^(?:a )?flash (notice|alert)$/
      ".flash.alert-#{$1} .message"

    when /^the (\w+)$/
      "##{$1}"

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

  # capybara uses the browsers' native query methods. Often they do not support CSS3
  def complicated_css(css)
    Nokogiri::CSS.xpath_for(css).first
  end

  def css2xpath(css)
    [:xpath, complicated_css(css)]
  end
end

World(HtmlSelectorsHelpers)
