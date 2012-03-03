When /^I scroll to the bottom$/ do
  page.execute_script <<-EOJS
    $(window).scrollTop( $(document).height() )
  EOJS
  step %Q~I wait for the spinner to stop~
end

When /^I wait for the spinner to start/ do
  wait_until { page.has_css?('#spinner', visible: true) }
end

When /^I wait for the spinner to stop$/ do
  wait_until(10) { page.has_no_css?('#spinner', visible: true) }
end

When /^the tick interval is reached$/ do
  page.execute_script <<-EOJS
    $('body').trigger('tick')
  EOJS
  step %Q~I wait for the spinner to stop~
end
