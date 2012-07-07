@javascript
Feature: Manage Library
  In order to manage my disk space properly
  I want to sort the contents of torrents into directories on disk


  @rootfs
  Scenario: can create directories
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And I am signed in
      And I am on the library page
     When I toggle the menu
      And I follow "Create Directory"
      And I wait for the modal box to appear
      And I select "aDisk" from "Disk"
      And I fill in "Name" with "Series"
      And I check "create on disk"
      And I press "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And a directory should exist with name: "Series", disk: the disk
      And the directory "media/adisk/Series" should exist on disk



      

