Then /^I should see a list of the following (\w+\s?\w+)(?!within.*):$/ do |plural, expected|
  plural = plural.split
  fields = expected.column_names.map(&:underscore).map {|f| ".#{f}" }
  found = page.find("ul.#{plural.join('.')}").all("li").select(&:visible?).map do |item|
    next if item[:class].include?('divider')
    fields.map {|f| item.first(f).text.strip rescue nil }
  end.reject {|l| l.all?(&:nil?)}
  expected.diff! found.unshift(expected.column_names)
end

Then /^I should see the following (\w+\s?\w+) in (.*):$/ do |items, container, expected|
  items = items.split.map(&:underscore).map(&:singularize).map {|f| ".#{f}" }.join
  fields = expected.column_names.map(&:underscore).map {|f| ".#{f}" }
  with_scope container do
    found = page.all(items).select(&:visible?).map do |item|
      next if item[:class].include?('divider')
      fields.map {|f| item.first(f).text.strip rescue nil }
    end
    expected.diff! found.unshift(expected.column_names)
  end
end

Then /^I should see a table of the following (\w+\s?\w+)(?!within.*):$/ do |plural, expected|
  plural = plural.split
  fields = expected.column_names.map(&:underscore).map {|f| "td.#{f}" }
  found = page.find("table.#{plural.join('.')} tbody").all("tr").select(&:visible?).map do |item|
    fields.map {|f| item.find(f).text.strip rescue nil }
  end.reject {|l| l.all?(&:nil?)}
  expected.diff! found.unshift(expected.column_names)
end

Then /^I should see the following breadcrumbs:$/ do |expected|
  found = page.all('ul.breadcrumb li').map(&:text).map(&:strip).map {|t| t.gsub(/\s+/, ' ') }.reject(&:blank?).map {|a| [a] }
  found.should_not be_empty
  expected.diff! found
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

Then /^I (should not|should) see "([^"]*)" in (\w+\s?\w+)(?!within.*)$/ do |should_or_not, text, container|
  page.send should_or_not.sub(/\s/,'_'), have_css(selector_for(container), text: text)
end

Then /^I should see the following attributes for the torrent:$/ do |table|
  table.rows_hash.each do |attr, value|
    selector = selector_for("the #{attr}") rescue ".#{attr}"
    step %Q~I should see "#{value}" within "#{selector}"~
  end
end
