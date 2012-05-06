@javascript
@rootfs
Feature: Disks in Library
  In order to create directories to store stuff in
  As a signed in user
  I want to register mounted drives

  Scenario: Disks are listed in the library
    Given the following disks exist:
      | name  |
      | Stuff |
      | More  |
      And I am signed in
     When I toggle the menu
      And I follow "Library"
      And I follow "All Directories"
     Then I should see a list of the following disks:
      | name  |
      | More  |
      | Stuff |

  Scenario: autodetect mounted disks
    Given the following disks are mounted:
      | path        |
      | var         |
      | media/Stuff |
      | media/More  |
      And I am signed in
     When I toggle the menu
      And I follow "Library"
      And I follow "All Directories"
     Then I should see "auto"
      And I should see a list of the following new disks:
      | name  |
      | More  |
      | Stuff |
      But I should not see "var"
      And I should not see "Var"
      When I follow "Stuff"
       And I press "Create Disk"
      Then a disk should exist with name: "Stuff"
       And I should be on the directories page of the disk
