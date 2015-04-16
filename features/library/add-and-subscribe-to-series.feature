@javascript
@rootfs
@rtorrent
@vcr
Feature: Add and Subscribe to Series
  In order to never miss another episode
  As a signed in user who is a tv addicte
  I want to add a Series
  And subscribe to it
  And immediately download the episodes already release

  Background:
    Given a disk exists with name: "aDisk", path: "media/adisk"
      And a directory exists with name: "Movies", disk: the disk, relative_path: "Movies"
      And I am signed in
      And I am on the home page
      And all animations are disabled


  Scenario: From empty disk to hours of episodes
     When I follow "Library"
      And I follow "aDisk" within the disks tab
      And I follow "Create Directory"
      And I wait for the modal box to appear
     Then the selected "Disk" should be "aDisk"
      And the selected "Parent" should be "[Root]"

     When I fill in "Name" with "Series"
      And I check "contains more directories"
      And I press "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And I should see "aDisk / Series" within the content title
      And a directory "Series" should exist with name: "Series", disk: the disk
      And the directory "media/adisk/Series" should exist on disk

     When I follow "Create Subdirectory"
      And I wait for the modal box to appear
     Then the selected "Disk" should be "aDisk"
      And the selected "Parent" should be "Series"
     When I fill in "Name" with "Shame of Frowns"
      And I check "subscribe"
      # TODo create automatically first, but offer field as auto-search
      And I fill in "Filter" with "shame frowns"
      And I press "Create Directory"
     Then I should see notice "Directory 'Series' created"
      And I should see "aDisk / Series / Shame of Frowns" within the content title
      And a directory "Frowns" should exist with name: "Shame of Frowns", disk: the disk
      And the directory "Series" should be the directory "Frowns"'s parent
      And the directory "media/adisk/Series/Shame of Frowns" should exist on disk

     When I follow "available episodes online"
     Then I should see the following remote torrents in a remote torrent list:
      | title                                                           |
      | Shame of Frowns S05E00 A Date in the Wife HDTV x264-EBAT [seti] |
      | Shame of Frowns - Season 1 - 720p BluRay - x264 - ShtlOrd       |
      | Shame of Frowns S03E09 HDTV x264-PULLERS[seti]                  |
      | Shame of Frowns S01E02 HDTV x264-PULLERS[seti]                  |
      | Shame of Frowns S01E01 HDTV x264-PULLERS[seti]                  |

     When I click on the start link within the second remote torrent
     Then I should not see any flash alert
      But I should see flash notice "Torrent was successfully created."
      And I should see the stop link within the second remote torrent
      But I should not see the start link within the second remote torrent
      And the tick interval is reached
      And I should see the following remote torrents in a remote torrent list:
      | title                                                           | percent |
      | Shame of Frowns S05E00 A Date in the Wife HDTV x264-EBAT [seti] |         |
      | Shame of Frowns - Season 1 - 720p BluRay - x264 - ShtlOrd       | 0%      |
      | Shame of Frowns S03E09 HDTV x264-PULLERS[seti]                  |         |
      | Shame of Frowns S01E02 HDTV x264-PULLERS[seti]                  |         |
      | Shame of Frowns S01E01 HDTV x264-PULLERS[seti]                  |         |
      And a torrent "Season" should exist with title: "Shame of Frowns - Season 1 - 720p BluRay - x264 - ShtlOrd"
      And the rtorrent main view should contain the torrent "Season"

     When I click on the start link within the third remote torrent
     Then I should see the stop link within the third remote torrent
      But I should not see the start link within the third remote torrent
      And the tick interval is reached
      And I should see the following remote torrents in a remote torrent list:
      | title                                                           | percent |
      | Shame of Frowns S05E00 A Date in the Wife HDTV x264-EBAT [seti] |         |
      | Shame of Frowns - Season 1 - 720p BluRay - x264 - ShtlOrd       | 0%      |
      | Shame of Frowns S03E09 HDTV x264-PULLERS[seti]                  | 0%      |
      | Shame of Frowns S01E02 HDTV x264-PULLERS[seti]                  |         |
      | Shame of Frowns S01E01 HDTV x264-PULLERS[seti]                  |         |
      And a torrent "Spoiler" should exist with title: "Shame of Frowns S03E09 HDTV x264-PULLERS[seti]"
      And the rtorrent main view should contain the torrent "Spoiler"
