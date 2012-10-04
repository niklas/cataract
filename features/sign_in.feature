Feature: Signing in
  In order to protect from misuse
  As a registered user
  I want to sign in

  @javascript
  Scenario: Signing in
    Given a registered user exists with email: "me@cataract.local"
     When I go to the home page
     Then I should be on the signin page
     When I fill in "Email" with "me@cataract.local"
      And I fill in "Password" with "secret"
      And I press "Sign in"
     Then I should see "Signed in successfully"
     # And I should see "me@cataract.local" within current user
      And I should be on the list page
