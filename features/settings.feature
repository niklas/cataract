Feature: Settings
  In order to setup my copy of cataract
  As a signed in user
  I want to specify some settings

  Scenario: Set default download directory
    Given the following directories exist:
      | directory | name     | id   |
      | Incoming  | Incoming | 1234 |
      | Archive   | Archive  | 4321 |
    Given I am signed in
     When I follow "Settings"
     Then I should be on the settings page
     When I select "Archive" from "Download directory"
      And I press "Save"
     Then I should see notice "Settings saved"
      And I should be on the settings page
      And a setting should exist
      And the setting's incoming_directory_id should be 4321

     When I select "Incoming" from "Download directory"
      And I press "Save"
     Then I should see notice "Settings saved"
      And I should be on the settings page
      And a setting should exist
      And the setting's incoming_directory_id should be 1234

