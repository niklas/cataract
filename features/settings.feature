@javascript
Feature: Settings
  In order to setup my copy of cataract
  As a signed in user
  I want to specify some settings

  Background:
    Given a user exists with email: "leecher@localhost.local"
      And I am signed in as the user

  Scenario: Set default download directory
    Given the following directories exist:
      | directory | name     | id   |
      | Incoming  | Incoming | 1234 |
      | Archive   | Archive  | 4321 |
      And I am on the home page
     When I toggle the menu
      And I follow "leecher@localhost.local"
      And I follow "Settings"
     When I select "Archive" from "Download directory"
      And I press "Save"
     Then I should see notice "Settings saved"
      And I should be on the settings page
      And a setting should exist
      And the setting's incoming_directory_id should be 4321

     When I select "Incoming" from "Download directory"
      And I press "Save"
     Then I should see notice "Settings saved"
      And a setting should exist
      And the setting's incoming_directory_id should be 1234

  Scenario: disable signup
    Given I am on the home page
     When I toggle the menu
      And I follow "leecher@localhost.local"
     When I follow "Settings"
     Then the "Disable signup" checkbox should not be checked
     When I check "Disable signup"
      And I press "Save"
     Then a setting should exist
      And the setting's disable_signup should be true
