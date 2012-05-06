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

  @rootfs
  Scenario: can create directories
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And I am signed in
     When I toggle the menu
      And I follow "Library"
      And I follow "Create Directory"
      And I wait for the modal box to appear
      And I select "aDisk" from "Disk"
      And I fill in "Name" with "Series"
      And I check "create on disk"
      And I press "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And a directory should exist with name: "Series", disk: the disk
      And the directory "media/adisk/Series" should exist on disk

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
     When I follow "Import Series"
      And I wait for the modal box to appear
     Then the "Name" field should contain "Series"
     When I press "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And a directory should exist with name: "Series", disk: the disk
      And the directory's path should end with "media/adisk/Series"
      And I should see a table of the following directories:
       | Name   |
       | Series |
      And I should see a table of the following new directories:
       | Name          |
       | Import Movies |


   Scenario: autodetect subdirectories 
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And the following filesystem structure exists on disk:
        | type      | path                          |
        | directory | media/adisk/Series/Tatort     |
        | directory | media/adisk/Series/Tagesschau |
      And a directory "Series" exists with name: "Series", disk: the disk, relative_path: "Series"
      And I am signed in
     When I toggle the menu
      And I follow "Library"
      And I follow "Series"
     Then I should see a table of the following new directories:
       | Name              |
       | Import Tagesschau |
       | Import Tatort     |
     When I follow "Import Tatort"
      And I wait for the modal box to appear
     Then the "Name" field should contain "Tatort"
     When I press "Create Directory"
     Then I should see notice "Directory 'Tatort' created"
      And a directory "Tatort" should exist with name: "Tatort", disk: the disk
      And the directory "Series" should be the directory "Tatort"'s parent
      And the directory "Tatort"'s path should end with "media/adisk/Series/Tatort"
      And I should see a table of the following directories:
       | Name   |
       | Tatort |
      And I should see a table of the following new directories:
       | Name              |
       | Import Tagesschau |

      

