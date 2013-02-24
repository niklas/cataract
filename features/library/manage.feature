@javascript
Feature: Manage Library
  In order to manage my disk space properly
  I want to sort the contents of torrents into directories on disk


  @rootfs
  Scenario: can create root directories
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And I am signed in
      And I am on the home page
     When I follow "aDisk"
      And I follow "Create Directory"
      And I wait for the modal box to appear
     Then the selected "Disk" should be "aDisk"
     #      And the selected "Parent" should be ""
     When I fill in "Name" with "Series"
      And I follow "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And a directory should exist with name: "Series", disk: the disk
      And the directory "media/adisk/Series" should exist on disk


  @wip
  @todo
  Scenario: can create subdirectories

