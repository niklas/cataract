@javascript
Feature: Subscribe Directory
  In order to never miss an episode of a series
  As a user
  I want to mark directories as subscribed

  Scenario: subscribe and unsubscribe a directory
    Given a directory exists with name: "Shame of Frowns"
      And I am signed in as user
      And am on the home page

     When I follow "Shame of Frowns" within the sidebar directories list
      And I check "subscribed" within the content
     Then the "Filter" field should contain "Shame of Frowns"
     When I fill in "Filter" with "frowns"
      And I press "Save"
     Then I should see flash notice "Directory 'Shame of Frowns' saved."
      And the directory should be subscribed
      And the directory's filter should be "frowns"

     When I follow "Shame of Frowns" within the sidebar directories list
     Then the "subscribed" checkbox should be checked
     When I uncheck "subscribed"
      And I press "Save"
     Then I should see flash notice "Directory 'Shame of Frowns' saved."
      And I pause
      And the directory should not be subscribed
