@javascript
Feature: Github integration
  In order to encourage people to participate
  I want to see the recent changes and create issues

  The current current commit is fixed to an old master, to actually find it
  while developing new features.

  Scenario: links to github
    Given a user exists with email: "leecher@localhost.local"
      And I am signed in as the user
      And I am on the home page
     When I toggle the menu
     Then I should see external link "Changes" pointing to "https://github.com/niklas/cataract/commits"
      And I should see external link "Updates" pointing to "https://github.com/niklas/cataract/compare"
      And I should see external link "Problems" pointing to "https://github.com/niklas/cataract/issues"
