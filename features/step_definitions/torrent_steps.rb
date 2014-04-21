When /^I (start|stop|load|refresh) #{capture_model}$/ do |action, m|
  model!(m).send :"#{action}!"
end

Given /^#{capture_model} was (load|start|stop|refresh)p?ed$/ do |m, action|
  step "I #{action} #{m}"
end

When /^I explore (the .+)$/ do |target|
  step 'all css animations are disabled'
  selector = selector_for(target)
  page.find(*selector).find('.title').click
end

Given /^archived torrents exist titled from "(.*?)" to "(.*?)" in reverse chronological order$/ do |from, to|
  (from..to).reverse_each do |title|
    FactoryGirl.create :torrent, title: title
  end
end

Then /^I should see the torrents titled from "(.*?)" to "(.*?)"$/ do |from, to|
  expected = (["Title"] + (from..to).to_a).map { |row| [row] }
  step %Q~I should see the following torrents in the torrent list:~, table(expected)
end
