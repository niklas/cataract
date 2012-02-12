Then /^#{capture_model}'s ([\w_]+) should not be ([\w_]+)$/ do |ref, method, predicate|
  model!(ref).send(method).should_not send("be_#{predicate}")
end

Given /^#{capture_model} is (running)$/ do |ref, status|
  model = model!(ref)
  model.update_attribute :status, status
end
