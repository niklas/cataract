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
      And a directory exists with name: "Movies", disk: the disk, relative_path: "Movies"
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
     Then I should see the following remote torrents in a torrent list:
      | title                                                           |
      | Shame of Frowns S05E00 A Date in the Wife HDTV x264-EBAT [seti] |
      | Shame of Frowns - Season 1 - 720p BluRay - x264 - ShtlOrd       |
      | Shame of Frowns S03E09 HDTV x264-PULLERS[seti]                  |
      | Shame of Frowns S01E02 HDTV x264-PULLERS[seti]                  |
      | Shame of Frowns S01E01 HDTV x264-PULLERS[seti]                  |

    Given the URL "http://torcache.net/torrent/AAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF.torrent?title=[kickass.to]shame.of.frowns.season.1.720p.bluray.x264.shtlord" points to file "single.torrent"
     When I click on the start link within the second torrent
     Then I should see the stop link
      But I should not see the start link
      And I should see the following remote torrents in a torrent list:
      | title                                                           | progress |
      | Shame of Frowns S05E00 A Date in the Wife HDTV x264-EBAT [seti] |          |
      | Shame of Frowns - Season 1 - 720p BluRay - x264 - ShtlOrd       |      0 % |
      | Shame of Frowns S03E09 HDTV x264-PULLERS[seti]                  |          |
      | Shame of Frowns S01E02 HDTV x264-PULLERS[seti]                  |          |
      | Shame of Frowns S01E01 HDTV x264-PULLERS[seti]                  |          |
      And a torrent "Season" should exist with title: "Shame of Frowns - Season 1 - 720p BluRay - x264 - ShtlOrd"
      And the rtorrent main view should contain the torrent "Season"

     When I click on the start link within the third torrent
     Then I should see the stop link within the third torrent
      But I should not see the start link within the third torrent
      And I should see the following remote torrents in a torrent list:
      | title                                                           | progress |
      | Shame of Frowns S05E00 A Date in the Wife HDTV x264-EBAT [seti] |          |
      | Shame of Frowns - Season 1 - 720p BluRay - x264 - ShtlOrd       |       0% |
      | Shame of Frowns S03E09 HDTV x264-PULLERS[seti]                  |       0% |
      | Shame of Frowns S01E02 HDTV x264-PULLERS[seti]                  |          |
      | Shame of Frowns S01E01 HDTV x264-PULLERS[seti]                  |          |
      And a torrent "Spoiler" should exist with title: "Shame of Frowns S03E09 HDTV x264-PULLERS[seti]"
      And the rtorrent main view should contain the torrent "Spoiler"
