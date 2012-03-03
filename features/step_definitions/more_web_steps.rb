When /^I filter the list with "([^"]+)"$/ do |terms|
  first('#torrent_search_terms').set(terms)
  step %q~I wait for the spinner to start~
  step %q~I wait for the spinner to stop~
end

When /^I click (?:on )?(the progress pie)$/ do |name|
  page.execute_script "$('#{selector_for(name)}').trigger('click')"
end

Given /^"([^"]*)" state should be chosen$/ do |state|
  step %Q~the "#{state}" checkbox should be checked~
end

When /^I choose state "([^"]*)"$/ do |state|
  first('label', text: state).click
end

When /^I toggle the (?:menu|navigation)$/ do
  page.execute_script %Q~$('a.btn-navbar').click()~
end
