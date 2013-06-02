Feature: disable signup
  In order to keep my download secret
  I want to disable the signup function

  Scenario: signup allowed by default
     When I go to the home page
     Then I should see "Sign up"
     When I follow "Sign up"
     Then I should see "Email"

  Scenario: disable signup by setting
    Given a setting exists with disable_signup: true
     When I go to the home page
     Then I should not see "Sign up"
     When I go to the signup page
     Then I should be on the sign in page
