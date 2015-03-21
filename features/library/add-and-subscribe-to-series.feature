@javascript
@rootfs
@vcr
Feature: Add and Subscribe to Series
  In order to never miss another episode
  As a signed in user who is a tv addicte
  I want to add a Series
  And subscribe to it
  And immediately download the episodes already release

  Background:
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And I am signed in
      And I am on the home page
      And all animations are disabled


  Scenario: From empty disk to hours of episodes
     When I follow "Library"
     Then I should see a table of the following disks:
      | Name  |
      | aDisk |
     When I follow "aDisk" within the disks table
      And I follow "Create Directory"
      And I wait for the modal box to appear
     Then the selected "Disk" should be "aDisk"

     When I fill in "Name" with "Series"
      And I check "contains more directories"
      And I press "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And I should see "Series" within the bar title
      And a directory "Series" should exist with name: "Series", disk: the disk
      And the directory "media/adisk/Series" should exist on disk

     When I follow "Create Subdirectory"
      And I wait for the modal box to appear
     Then the selected "Disk" should be "aDisk"
      And the selected "Parent" should be "Series"
     When I fill in "Name" with "Shame of Frowns"
      And I check "subscribed"
      And I fill in "Filter" with "shame frowns"
      And I press "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And I should see "Series/Shame of Frowns" within the bar title
      And a directory "Frowns" should exist with name: "Shame of Throwns", disk: the disk, parent: the directory "Series"
      And the directory "media/adisk/Series/Shame of Frowns" should exist on disk

     When I follow "available episodes online"
     Then I should see the following torrents in the torrent list:
      | title                  |
      | Shame of Frowns S03E09 |
      | Shame of Frowns S01E02 |
      | Shame of Frowns S01E01 |
     When I explore the first torrent
      And I click on the start link
      And I wait for the spinner to disappear
     Then I should see the stop link
      But I should not see the start link
      And I should see "Shame of Frowns S03E09" within the bar title
      And a torrent "Spoiler" should exist with name: "Shame of Frowns S03E09"
      And the rtorrent main view should contain the torrent "Spoiler"

     When I explore the third torrent
      And I click on the start link
      And I wait for the spinner to disappear
     Then I should see the stop link
      But I should not see the start link
      And I should see "Shame of Frowns S01E01" within the bar title
      And a torrent "Pilot" should exist with name: "Shame of Frowns S01E01"
      And the rtorrent main view should contain the torrent "Pilot"
