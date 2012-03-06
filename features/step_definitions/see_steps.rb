Then /^I should see a list of the following (\w+):$/ do |plural, expected|
  fields = expected.column_names.map(&:underscore).map {|f| ".#{f}" }
  found = page.find("ul.#{plural}").all("li").select(&:visible?).map do |item|
    fields.map {|f| item.find(f).text.strip }
  end
  expected.diff! found.unshift(expected.column_names)
end

Then /^the button "([^"]*)" should be active$/ do |label|
  item = page.find("a.ui-btn", :text => label)
  item['class'].split.should include('ui-btn-active')
end

Then /^I should see (?:flash )?(notice|alerts) "([^"]*)"$/ do |severity, message|
  step %Q~I should see "#{message}" within flash #{severity}~
end

Then /^I should see no link "([^"]*)"$/ do |label|
  page.should have_no_css('a', :text => label)
end

Then /^I should see the following attributes for the torrent:$/ do |table|
  table.rows_hash.each do |attr, value|
    selector = selector_for("the #{attr}") rescue ".#{attr}"
    step %Q~I should see "#{value}" within "#{selector}"~
  end
end
