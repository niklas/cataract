@rtorrent
@rootfs
Feature: recognize torrents
  In order to not having to log in every day
  As a lazy user
  I want downloads recognized automatically

  Scenario: recognize torrents only in watched directories
    Given a disk exists with path: "media"
      And the following directories exist:
        | directory | relative_path | watched | disk     |
        | torrents  | torrents      | true    | the disk |
        | else      | else          | false   | the disk |
      And the following filesystem structure exists on disk:
        | type | path                           |
        | file | media/torrents/oneiric.torrent |
        | file | media/else/natty.torrent       |
     When the Recognizer runs
     Then a torrent should exist with filename: "oneiric.torrent"
      And directory "torrents" should be the torrent's content_directory
      And the torrent's info_hash should not be blank
      But 0 torrents should exist with filename: "natty.torrent"

  Scenario: recognize torrents are downloaded automatically
    Given a disk exists with path: "media"
      And the following directories exist:
        | directory | relative_path | watched | disk     |
        | torrents  | torrents      | true    | the disk |
      And the following filesystem structure exists on disk:
        | type | path                           |
        | file | media/torrents/oneiric.torrent |
     When the Recognizer runs
     Then a torrent should exist with filename: "oneiric.torrent"
      And the torrent's current_state should be "running"
      And rtorrent should download the torrent

  @todo
  Scenario: notify users by jabber

  @todo
  Scenario: recognize torrent's contents somewhere (with mlocate)

  @vcr
  Scenario: auto-fetch torrents for tv-shows in subscribed directories
    Given a disk exists with path: "media"
      And a torrent exists with filename: "[kickass.to]ow-my-balls-s23e44.720p.x264.hdtv.mvgroup.org.torrent"
      And the following directories exist:
        | directory | relative_path | subscribed | filter | disk     |
        | torrents  | torrents      | true       | o      | the disk |
      And a feed exists with url: "https://kickass.to/usearch/user:eztv/?rss=1"
     When the Recognizer runs
     Then a torrent should exist with title: "Electophobia S01E02"
      And the torrent's filename should be "[kickass.to]elecophobia.s010e02.720p.x264.hdtv.mvgroup.org.torrent"
      And directory "torrents" should be the torrent's content_directory
      And the torrent's file should exist on disk
      And the torrent's info_hash should not be blank
      And the torrent's current_state should be "running"

      # did not match filter
      And a torrent should not exist with title: "Cakes S06E25"
      # already exists ( by filename )
      But a torrent should not exist with title: "Ow my Balls S23E44"


  @todo
  Scenario: recognize torrents that were added manually to rtorrent
