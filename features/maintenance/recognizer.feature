@rtorrent
@rootfs
Feature: recognize torrents
  In order to not having to log in every day
  As a lazy user
  I want downloads recognized automatically

  Scenario: recognize torrents only in watched directories
    Given the following directories exist:
        | directory | path           | watched |
        | torrents  | media/torrents | true    |
        | else      | media/else     | false   |
      And the following filesystem structure exists on disk:
        | type | path                           |
        | file | media/torrents/oneiric.torrent |
        | file | media/else/natty.torrent       |
     When the Recognizer runs
     Then a torrent should exist with filename: "oneiric.torrent"
      And directory "torrents" should be the torrent's directory
      And directory "torrents" should be the torrent's content_directory
      And the torrent's info_hash should not be blank
      But 0 torrents should exist with filename: "natty.torrent"

  Scenario: recognize torrents are downloaded
    Given the following directories exist:
        | directory | path           | watched |
        | torrents  | media/torrents | true    |
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
  Scenario: recognize torrents somewhere (with mlocate)

  @todo
  Scenario: auto-fetch torrents for tv-shows

  @todo
  Scenario: recognize torrents added manually to rtorrent
