module BrowserInspectorHelper

  def open_ember_inspector
    ember_inspector_bookmarklet = <<-EOJS
      (function() { var s = document.createElement('script'); s.src = '//ember-extension.s3.amazonaws.com/dist_bookmarklet/load_inspector.js'; document.body.appendChild(s); })();
    EOJS
    page.execute_script ember_inspector_bookmarklet
  end

end

World(BrowserInspectorHelper)

When /^I pause$/ do
  STDERR.puts "Pausing..."
  if system(%Q~zenity --question --text="Paused. Want to pry?"~)
    binding.pry
  end
end

When /^I debug the page$/ do
  if @debugging_page
    page.driver.pause
  else
    @debugging_page = true
    page.driver.debug
  end
end

After do
  @debugging_page = false
end

When /^nothing$/ do
  # for scenario outlines
end

When /^I wait (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end
