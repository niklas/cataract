When /^I filter with "([^"]+)"$/ do |terms|
  find('#torrent_search_terms').set(terms)
  sleep 1 # delayed typing
end

When /^I click (?:on )?(the progress pie)$/ do |name|
  page.execute_script "$('#{selector_for(name)}').trigger('click')"
end

Given /^"([^"]*)" state should be chosen$/ do |state|
  step %Q~the "#{state}" checkbox should be checked~
end

When /^I choose state "([^"]*)"$/ do |state|
  find('label', text: state).click
end

When /^I toggle the (?:menu|navigation)$/ do
  page.find('#session a.dropdown-toggle').click
end

When(/^I go back$/) do
  page.execute_script %Q~window.history.back()~
end

# capybara does not see text in "head > title"
Then /^the window title should include "([^"]+)"$/ do |part|
  sel = selector_for('the window title')
  title = evaluate_script %Q~$('#{sel}').text()~
  title.should include(part)
end

Then /^the selected "([^"]*)" should be "([^"]*)"$/ do |field, value|
  field = field_labeled(field)
  options = field.all('option')
  options.should_not be_empty, 'no options found'
  selected = options.find(&:selected?)
  selected.should_not be_blank, 'nothing selected'
  selected.text.should =~ /#{value}/
end

When /^I wait for (.+) to (?:appear|start)$/ do |name|
  selector = selector_for name
  page.should have_css(selector, :visible => true)
end

When /^I wait for (.+) to (?:disappear|stop)$/ do |name|
  selector = selector_for name
  patiently 30 do # spinner may flicker
    page.should have_no_css(selector, :visible => true)
  end
end

Then /^(.+) should be visible/ do |name|
  step %Q~I wait for #{name} to appear~
end

Then /^(.+) should disappear$/ do |name|
  step %Q~I wait for #{name} to disappear~
end

When /^I click on (the (?:#{match_nth})?\s?\w+\s?\w+)(?!within.*)$/ do |target|
  selector = selector_for(target)
  page.should have_css(selector)
  page.find(selector).click
  wait_for_the_page_to_be_loaded
end

Then /^I should see (.+link)$/ do |target|
  page.should have_css( selector_for(target) )
end

Then /^I should not see (.+link)$/ do |target|
  page.should have_no_css( selector_for(target) )
end

Then /^I should be under page "(.*?)"$/ do |url_prefix|
  current_url.should be_starts_with(url_prefix)
end

When /^I open the (settings|feeds) menu$/ do |entry|
  page.find('#session a.dropdown-toggle').click
  step %Q~I follow "#{entry.capitalize}"~
end

When /^(.*) in frame "([^"]+)"$/ do |inner, frame_id|
  page.should have_css("iframe##{frame_id}") # wait for it...
  within_frame frame_id do
    step inner
  end
end

Given /^all (?:css )?animations are disabled$/ do
  execute_script <<-EOJS
    $('<style></style>')
      .text("* { transition-property: none !important };")
      .appendTo('html head')
  EOJS
  execute_script 'jQuery.fx.off = true'
end

When /^I close all flash messages$/ do
  step 'all animations are disabled'
  all('.flash .close').each(&:click)
end

Then /^(?:|I )should see "([^"]*)" as status title$/ do |text|
  page.should have_css(".status[title='#{text}']")
end
