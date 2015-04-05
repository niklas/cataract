@javascript
Feature: Subscribe Directory
  In order to never miss an episode of a series
  As a user
  I want to mark directories as subscribed

  Scenario: subscribe and unsubscribe a directory
    Given a disk exists with name: "aDisk"
      And a directory exists with name: "Shame of Frowns", disk: the disk
      And I am signed in as user
      And am on the library page
      And I wait for the spinner to stop
      And all animations are disabled

    Given I should not see "Same of Frowns"
      And I follow "all Directories"

     When I follow "Shame of Frowns" within the sidebar directories list
      And I follow "aDisk" within the disks tab
     Then I should see "aDisk / Shame of Frowns" within the content title

     When I follow "subscribe"
     Then the "Filter" field should contain "Shame of Frowns"
      And the directory's subscribed should be false

     When I fill in "Filter" with "frowns"
      And I follow "Save"
     Then I should see flash notice "Directory 'Shame of Frowns' saved."
      And I should see "subscribed" in a label within the content
      And the directory's subscribed should be true
      And the directory's filter should be "frowns"

     When I follow "unsubscribe"
      And I follow "Cancel"
     Then I should see "subscribed" in a label within the content
      And the directory's subscribed should be true

     When I close all flash messages
      And I follow "unsubscribe"
      And I follow "Save"
     Then I should see flash notice "Directory 'Shame of Frowns' saved."
      #Then I should see flash notice "subscribed to Directory 'Shame of Frowns'."
      And I should not see "subscribed" in a label within the content
      And the directory's subscribed should be false

      And I should not see "Save"
