Given /^I am signed in$/ do
  step %Q~I am signed in as a registered user~
end

Given /^I am signed in as #{capture_model}$/ do |user|
  unless user.include?('the')
    step %{#{user} exists}
  end
  user = model!(user)
  visit fast_sign_in_path(email: user.email)
  page.should have_content('success')
end
