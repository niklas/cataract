When /^I scroll to the bottom$/ do
  page.execute_script <<-EOJS
    $(window).scrollTop( $(document).height() )
  EOJS
  step %Q~I wait for the spinner to stop~
end

When /^the tick interval is reached$/ do
  page.execute_script <<-EOJS
    $('body').trigger('tick')
  EOJS
  step %Q~I wait for the spinner to stop~
  sleep 1 # give ember a second
end

When /^I confirm popup$/ do
  page.driver.browser.switch_to.alert.accept
end
