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
      | media/Stuff |
      | media/More  |
      And I am signed in
     When I toggle the menu
      And I follow "Library"
      And I follow "All Directories"
     Then I should see a list of the following new disks:
      | name  |
      | More  |
      | Stuff |
      When I follow "Stuff"
       And I press "Create Disk"
      Then a disk should exist with name: "Stuff"
