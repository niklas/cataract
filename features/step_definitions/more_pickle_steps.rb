Then /^#{capture_model}'s ([\w_]+) should not be ([\w_]+)$/ do |ref, method, predicate|
  model!(ref).send(method).should_not send("be_#{predicate}")
end

