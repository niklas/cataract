@javascript
Feature: Settings
  In order to setup my copy of cataract
  As a signed in user
  I want to specify some settings

  Background:
    Given a user exists with email: "leecher@localhost.local"
      And a disk exists with name: "More"
      And the following directories exist:
      | directory | name     | id   | disk     |
      | Incoming  | Incoming | 1234 | the disk |
      | Archive   | Archive  | 4321 | the disk |
      And I am signed in as the user
      And I am on the home page
      And all animations are disabled
      And I open the settings menu

  Scenario: Set default download directory
     When I select "Archive (More)" from "Download Directory"
      And I press "Save"
     Then I should see notice "Settings saved"
      And I should be on the home page
      And a setting should exist
      And the setting's incoming_directory_id should be 4321

     When I select "Incoming (More)" from "Download Directory"
      And I press "Save"
     Then I should see notice "Settings saved"
      And a setting should exist
      And the setting's incoming_directory_id should be 1234

  Scenario: disable signup
    Given the "Disable signup" checkbox should not be checked
     When I check "Disable signup"
      And I press "Save"
     Then I should see notice "Settings saved"
      And a setting should exist
      And the setting's disable_signup should be true
