Then /^#{capture_model}'s ([\w_]+) should not be ([\w_]+)$/ do |ref, method, predicate|
  model!(ref).send(method).should_not send("be_#{predicate}")
end

Given /^#{capture_model} is (?:marked as )?(running)$/ do |ref, status|
  model = model!(ref)
  model.update_attribute :status, status
  Torrent.remote.clear_caches!
end

Then(/^#{capture_model}'s (\w+) (should(?: not)?) end with #{capture_value}$/) do |name, attribute, expectation, expected|
  actual_value  = model(name).send(attribute)
  expectation   = expectation.gsub(' ', '_')

  actual_value.to_s.send(expectation, be_ends_with(eval(expected)))
end
