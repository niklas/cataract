@javascript
Feature: Enter the library
  In order to always know what I can watch, install or delete
  As a user
  I want to open the library to browse my finished downloads

  Scenario: accessible through the menu
    Given I am signed in
     When I toggle the menu
      And I follow "Library"
      And I follow "All Directories"
     Then I should be on the library page
