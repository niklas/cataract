When /^I filter the list with "([^"]+)"$/ do |terms|
  first('.ui-input-search input.ui-input-text').set(terms)
  step %q~I wait for the spinner to stop~
end

When /^I click (?:on )?(the progress pie)$/ do |name|
  page.execute_script "$('#{selector_for(name)}').trigger('click')"
end
