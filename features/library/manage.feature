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
      And I wait for the modal box to appear
      And I select "aDisk" from "Disk"
      And I fill in "Name" with "Series"
      And I press "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And a directory should exist with name: "Series", disk: the disk

  @rootfs
  Scenario: autodetect directories on disk
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And the following filesystem structure exists on disk:
        | type      | path               |
        | directory | media/adisk/Series |
        | directory | media/adisk/Movies |
      And I am signed in
     When I toggle the menu
      And I follow "Library"
      And I follow "All Directories"
     Then I should see a table of the following new directories:
       | Name          |
       | Import Movies |
       | Import Series |
     When I follow "import Series"
      And I wait for the modal box to appear
     Then the "Name" field should contain "Series"
     When I press "Create Directory"
      And I wait for the modal box to disappear
     Then I should see notice "Directory 'Series' created"
      And a directory should exist with name: "Series", disk: the disk
      And I should see a table of the following directories:
       | Name   |
       | Series |
      And I should see a table of the following new directories:
       | Name          |
       | Import Movies |
      

