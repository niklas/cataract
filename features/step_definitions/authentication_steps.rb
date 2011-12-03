Given /^I am signed in$/ do
  step %Q~I am signed in as a registered user~
end

Given /^I am signed in as #{capture_model}$/ do |user|
  unless user.include?('the')
    step %{#{user} exists}
  end
  user = model!(user)
  step %{I am on the home page}
  step %{I fill in "Email" with "#{user.email}"}
  step %{I fill in "Password" with "#{FactoryGirl::Password}"}
  step %{I press "Sign in"}
  # step %{I should see "Signed in successfully"}
   # And %{I should see "#{user.email}" within current user}
end
