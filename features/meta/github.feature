@javascript
Feature: Github integration
  In order to encourage people to participate
  I want to see the recent changes and create issues

  The current current commit is fixed to an old master, to actually find it
  while developing new features.

  Background:
    Given a user exists with email: "leecher@localhost.local"
      And I am signed in as the user
      And I am on the home page
     When I toggle the menu
      And I follow "leecher@localhost.local"

  Scenario: Changes until our version
     When I follow "Changes"
     Then I should see "GitHub Inc. All rights reserved."
      And I should see "Commit History"

  Scenario: What's new against official release
     When I follow "Updates"
     Then I should see "GitHub Inc. All rights reserved."
      And I should see "Compare View"

  Scenario: Issues
     When I follow "Problems"
     Then I should see "GitHub Inc. All rights reserved."
      And I should see "Browse Issues"

