Then /^I should see a list of the following (\w+\s?\w+)(?!within.*):$/ do |plural, expected|
  plural = plural.split
  fields = expected.column_names.map(&:underscore).map {|f| ".#{f}" }
  found = page.find("ul.#{plural.join('.')}").all("li").select(&:visible?).map do |item|
    next if item[:class].include?('divider')
    fields.map {|f| item.first(f).text.strip rescue nil }
  end.reject {|l| l.all?(&:nil?)}
  expected.diff! found.unshift(expected.column_names)
end

# Then I should see the following mounted disks in the sidebar disk list:
Then /^I should see the following (\w+\s?\w+) in (.*):$/ do |item_names, container_name, expected|
  items = item_names.split.map(&:underscore).map(&:singularize).map {|f| ".#{f}" }.join
  fields = expected.column_names.map(&:underscore).map {|f| ".#{f}" }
  found = page.all("#{selector_for(container_name)} >*#{items}").select(&:visible?).map do |item|
    next if item[:class].include?('divider')
    fields.map {|f| item.first(f).text.strip rescue '(i) nil' }
  end
  expected.diff! found.unshift(expected.column_names)
end

Then /^I should see a table of the following (\w+\s?\w+)(?!within.*):$/ do |plural, expected|
  plural = plural.split
  fields = expected.column_names.map(&:underscore).map {|f| "td.#{f}, .#{f}" }
  found = page.find("table.#{plural.join('.')} tbody").all("tr").select(&:visible?).map do |item|
    fields.map {|f| item.first(f).text.strip rescue nil }
  end.reject {|l| l.all?(&:nil?)}
  expected.diff! found.unshift(expected.column_names)
end

Then /^I should see the following breadcrumbs:$/ do |expected|
  found = page.all('ul.breadcrumb li').map(&:text).map(&:strip).map {|t| t.gsub(/\s+/, ' ') }.reject(&:blank?).map {|a| [a] }
  found.should_not be_empty
  expected.diff! found
end

# Then the torrent list should be empty
Then /^(the.*list) should be empty$/ do |container_name|
  found = page.all("#{selector_for(container_name)} >*").select(&:visible?)
  found.should be_empty
end

# Then the active nav item should be "Recent"
Then /^(the[^"']+) should be "([^"]+)"$/ do |name, label|
  patiently 30 do
    page.should have_css(*selector_for(name), text: label)
  end
end

Then /^I should see (?:flash )?(notice|alert) "([^"]*)"$/ do |severity, message|
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
    selector = if attr.include?('_')
                 ".#{attr}"
               else
                 selector_for("the #{attr}") rescue ".#{attr}"
               end
    step %Q~I should see "#{value}" within "#{selector}"~
  end
end

Then /^(.*) (should|should not) be classified as (\w+)$/ do |name, should_or_not, klass|
  selector = selector_for(name)
  element = page.first(selector)

  if should_or_not.include?('not')
    element['class'].should_not =~ /\b#{klass}\b/
  else
    element['class'].should =~ /\b#{klass}\b/
  end
end

When /^I should see external link "(.*?)" pointing to "(.*?)"$/ do |title, href|
  link = find_link title
  link.should be_present
  link[:href].should start_with( href )
end

