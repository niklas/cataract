When /^I filter with "([^"]+)"$/ do |terms|
  first('#torrent_search_terms').set(terms)
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
  sleep 0.5
end

When(/^I go back$/) do
  page.execute_script %Q~window.history.back()~
end

Then /^the selected "([^"]*)" should be "([^"]*)"$/ do |field, value|
  field_labeled(field).all('option').find(&:selected?).text.should =~ /#{value}/
end

When /^I wait for (.+) to (?:appear|start)$/ do |name|
  selector = selector_for name
  page.should have_css(selector, :visible => true)
end

When /^I wait for (.+) to (?:disappear|stop)$/ do |name|
  selector = selector_for name
  page.should have_no_css(selector, :visible => true)
end

Then /^(.+) should be visible/ do |name|
  step %Q~I wait for #{name} to appear~
end

Then /^(.+) should disappear$/ do |name|
  step %Q~I wait for #{name} to disappear~
end

When /^I click on (the .+)$/ do |target|
  selector = selector_for(target)
  page.should have_css(selector)
  page.first(selector).click
end

Then /^I should see (.+link)/ do |target|
  page.should have_css( selector_for(target) )
end

Then /^I should not see (.+link)/ do |target|
  page.should have_no_css( selector_for(target) )
end

Then /^I should be under page "(.*?)"$/ do |url_prefix|
  current_url.should be_starts_with(url_prefix)
end
