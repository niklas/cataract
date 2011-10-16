Feature: Signing in
  In order to protect from misuse
  As a registered user
  I want to sign in

  Scenario: Signing in
    Given a registered user exists with email: "me@cataract.local"
      And I am on the home page
     When I fill in "Email" with "me@cataract.local"
      And I fill in "Password" with "secret"
      And I press "Sign In"
     Then I should see "Successfully logged in"

