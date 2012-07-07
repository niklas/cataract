@javascript
@rootfs
Feature: Disks in Library
  In order to create directories to store stuff in
  As a signed in user
  I want to register mounted drives

  Background:
    Given I am signed in


  Scenario: autodetect mounted disks
    Given the following disks are mounted:
      | path        |
      | var         |
      | media/Stuff |
      | media/More  |
     When I go to the library page
     Then I should see "Detected" within the sidebar
      And I should see the following new disks in the sidebar disks list:
      | name  |
      | More  |
      | Stuff |
      But I should not see "var"
      And I should not see "Var"
      When I follow "Stuff"
       And I press "Create Disk"
      Then a disk should exist with name: "Stuff"
       And I should be on the page of the disk

  Scenario: autodetect directories on disk
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And the following filesystem structure exists on disk:
        | type      | path               |
        | directory | media/adisk/Series |
        | directory | media/adisk/Movies |
     When I go to the library page
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
      And I should be on the page of the disk
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
    Given I am on the library page
     When I follow "Series" within the directories list
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
