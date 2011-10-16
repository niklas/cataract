Given /^I am signed in$/ do
  Given %Q~I am signed in as a registered user~
end

Given /^I am signed in as #{capture_model}$/ do |user|
  unless user.include?('the')
    Given %{#{user} exists}
  end
  user = model!(user)
  Given %{I am on the home page}
    And %{I fill in "Email" with "#{user.email}"}
    And %{I fill in "Password" with "#{FactoryGirl::Password}"}
    And %{I press "Sign in"}
   Then %{I should see "Signed in successfully"}
    And %{I should see "#{user.email}" within current user}
end
