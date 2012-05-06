@fakefs
Feature: Assigning directories
  In order to eactly locate the torrent files
  As a horder
  I want to have directories assigned to exactly matching directories


  Scenario: catches exact path
   Given the following filesystem structure exists on disk:
       | type | path                                      |
       | file | /media/more/torrents/Lost_7x01.torrent    |
       | file | /media/more/torrents/archive/tkkg.torrent |
     And a disk exists with path: "/media/more"
     And the following directories exist:
       | directory | disk     | relative_path    |
       | torrents  | the disk | torrents         |
       | archive   | the disk | torrents/archive |
     And the following dirless torrents exist:
       | dirless torrent | filename          |
       | Lost            | Lost_7x01.torrent |
       | tkkg            | tkkg.torrent      |

    When the DirectoryAssigner runs
    Then 2 torrents should exist
     And the directory "torrents" should be the torrent "Lost"'s directory
     And the directory "archive" should be the torrent "tkkg"'s directory
