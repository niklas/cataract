Then /^I should see a list of the following (.+):$/ do |plural, expected|
  fields = expected.column_names.map(&:underscore).map {|f| ".#{f}" }
  found = page.find("ul.#{plural}").all("li").map do |item|
    fields.map {|f| item.find(f).text }
  end
  expected.diff! found.unshift(expected.column_names)
end

Then /^the item "([^"]*)" should be active$/ do |label|
  item = page.find("li", :text => label)
  item['class'].split.should include('active')
end
