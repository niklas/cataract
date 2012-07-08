@javascript
Feature: Changes
  In order to try out ALL the features
  As a user
  I want to see the recent changes

  Background:
    Given a user exists with email: "leecher@localhost.local"
    Given I am signed in as the user
      And I am on the home page
     When I toggle the menu
      And I follow "leecher@localhost.local"

  Scenario: Changes until our version
     When I follow "Changes"
     Then I should see "© 2012 GitHub Inc. All rights reserved."
      And I should see "Commit History"

  Scenario: What's new against official release
     When I follow "Updates"
     Then I should see "© 2012 GitHub Inc. All rights reserved."
      And I should see "Compare View"

