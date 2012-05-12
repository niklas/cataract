Feature: disable signup
  In order to keep my download secret
  I want to disable the signup function

  Scenario: signup allowed by default
     When I go to the home page
     Then I should see "Signup"
     When I follow "Signup"
     Then I should see "Email"

  Scenario: setting it
    Given I am signed in
     When I follow "Settings"
     Then the "Disable signup" checkbox should not be checked
     When I check "Disable signup"
      And I press "Save"
     Then a setting should exist
      And the setting's disable_signup should be true

  Scenario: disable signup by setting
    Given a setting exists with disable_signup: true
     When I go to the home page
     Then I should not see "Signup"
     When I go to the signup page
     Then I should see "Access Denied"
