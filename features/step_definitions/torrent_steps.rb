When /^I (start|stop|load|refresh) #{capture_model}$/ do |action, m|
  model!(m).send :"#{action}!"
end

Given /^#{capture_model} was (load|start|stop|refresh)p?ed$/ do |m, action|
  step "I #{action} #{m}"
end
