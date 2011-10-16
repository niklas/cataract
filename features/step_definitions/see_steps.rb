Then /^I should see a list of the following (.+):$/ do |plural, expected|
  fields = expected.column_names.map(&:underscore).map {|f| ".#{f}" }.join(',')
  found = page.all("ul.#{plural} li").map do |item|
    item.all(fields).map(&:text)
  end
  expected.diff! found.unshift(expected.column_names)
end
