@javascript
Feature: Subscribe Directory
  In order to never miss an episode of a series
  As a user
  I want to mark directories as subscribed

  Scenario: subscribe and unsubscribe a directory
    Given a directory exists with name: "Shame of Frowns"
      And I am signed in as user
      And am on the library page

     When I follow "Shame of Frowns" within the directories list
      And I follow "Edit"
      And I wait for the modal box to appear
      And I check "subscribed"
     Then the "Filter" field should contain "Shame of Frowns"
     When I fill in "Filter" with "frowns"
      And I press "Save"
     Then I should see flash notice "Directory 'Shame of Frowns' saved."
      And I should see a table of the following directories:
       | Name            | subscribed |
       | Shame of Frowns | yes        |
      And the directory should be subscribed
      And the directory's filter should be "frowns"

     When I follow "Shame of Frowns" within the directories list
      And I follow "Edit"
      And I wait for the modal box to appear
     Then the "subscribed" checkbox should be checked
     When I uncheck "subscribed"
      And I press "Save"
     Then I should see flash notice "Directory 'Shame of Frowns' saved."
      And I should see a table of the following directories:
       | Name            | subscribed |
       | Shame of Frowns | no         |
