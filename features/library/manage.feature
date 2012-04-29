@javascript
Feature: Manage Library
  In order to manage my disk space properly
  I want to sort the contents of torrents into directories on disk


  Scenario: Root directories are listed in the menu
    Given the following directories exist:
      | name   |
      | Series |
      | Movies |
    Given I am signed in
     When I toggle the menu
      And I follow "Library"
     Then I should see a list of the following directories:
       | name   |
       | Movies |
       | Series |

  Scenario: can create directories
    Given a disk exists with name: "aDisk"
      And I am signed in
     When I toggle the menu
      And I follow "Library"
      And I follow "Create Directory"
      And I select "aDisk" from "Disk"
      And I fill in "Name" with "Series"
      And I press "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And a directory should exist with name: "Series", disk: the disk

  Scenario: autodetect directories on disk
    Given a disk exists with name: "aDisk"
      And I am signed in
     When I toggle the menu
      And I follow "Library"
      And I follow "All Directories"
     Then I should see a table of the following new directories:
       | Name   |
       | Series |
       | Movies |
     When I press "import Series"
     Then I should see notice "Directory 'Series' created"
      And a directory should exist with name: "Series", disk: the disk
      

