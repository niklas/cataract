When /^I scroll to the bottom$/ do
  page.execute_script <<-EOJS
    $(window).scrollTop( $(document).height() )
  EOJS
  step %Q~I wait for the spinner to stop~
end

When /^I wait for the spinner to stop$/ do
  page.should have_no_css('span.ui-icon-loading')
end
