@javascript
Feature: Subscribe Directory
  In order to never miss an episode of a series
  As a user
  I want to mark directories as subscribed

  Scenario: subscribe and unsubscribe a directory
    Given a directory exists with name: "Shame of Frowns"
      And I am signed in as user
      And am on the home page
      And I wait for the spinner to stop

     When I follow "Shame of Frowns" within the sidebar root directories list
     Then I should see "Shame of Frowns" within the details
     When I click on the edit link
      And I wait for the modal box to appear
      And I check "subscribed"
     Then the "Filter" field should contain "Shame of Frowns"
     When I fill in "Filter" with "frowns"
      And I follow "Save"
      And I wait for the modal box to disappear
     Then I should see flash notice "Directory 'Shame of Frowns' saved."
      And I should see "subscribed" in a label within the details
      And the directory should be subscribed
      And the directory's filter should be "frowns"

     When I click on the edit link
      And I wait for the modal box to appear
      And I uncheck "subscribed"
      And I follow "Cancel"
      And I wait for the modal box to disappear
     Then I should see "subscribed" in a label within the details
      And the directory should be subscribed

     When I click on the edit link
      And I wait for the modal box to appear
     Then the "subscribed" checkbox should be checked
     When I uncheck "subscribed"
      And I follow "Save"
      And I wait for the modal box to disappear
      #Then I should see flash notice "subscribed to Directory 'Shame of Frowns'."
      And I should not see "subscribed" in a label within the details
      And the directory should not be subscribed
