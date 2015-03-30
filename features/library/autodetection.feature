# encoding: utf-8
@javascript
@rootfs
Feature: Disks in Library
  In order to create directories to store stuff in
  As a signed in user
  I want to register mounted drives

  Background:
    Given I am signed in


  # TODO: where do we put disk import?
  @wip
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

  Scenario: autodetect root directories on disk
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And the following filesystem structure exists on disk:
        | type      | path               |
        | directory | media/adisk/Series |
        | directory | media/adisk/Movies |
        | directory | media/adisk/Röbels |
     When I go to the library page
      And I follow "aDisk" within the content
     Then I should see a list of the following new directories:
       | Name   |
       | Movies |
       | Röbels |
       | Series |
     When I follow "Import" within the third of the new directories
      And I wait for the spinner to disappear
     Then I should see notice "Directory 'Series' created"
      And a directory should exist with name: "Series", disk: the disk
      And the directory's full_path should end with "media/adisk/Series"
      And I should see a list of the following existing directories:
       | Name   |
       | Series |
      And I should see a list of the following new directories:
       | Name   |
       | Movies |
       | Röbels |

   Scenario: autodetect subdirectories
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And the following filesystem structure exists on disk:
        | type      | path                          |
        | directory | media/adisk/Series/Tatort     |
        | directory | media/adisk/Series/Tagesschau |
      And a directory "Series" exists with name: "Series", disk: the disk, relative_path: "Series", show_sub_dirs: true
      And I am on the library page
      And I follow "all Directories"
     When I follow "Series" within the sidebar directory list
      # TODO should indicate that there are more details
      And I follow "aDisk" within the detail bar
      And I wait for the spinner to stop
     Then I should see a list of the following new directories:
       | Name       |
       | Tagesschau |
       | Tatort     |
     When I follow "Import" within the second of the new directories
      And I wait for the spinner to stop
     Then I should see notice "Directory 'Tatort' created"
      And a directory "Tatort" should exist with name: "Tatort", disk: the disk
      And the directory "Series" should be the directory "Tatort"'s parent
      And the directory "Tatort"'s full_path should end with "media/adisk/Series/Tatort"
      And I should see a list of the following existing directories:
       | Name   |
       | Tatort |
      And I should see a list of the following new directories:
       | Name       |
       | Tagesschau |
