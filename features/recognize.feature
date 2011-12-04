@fakefs
Feature: recognize torrents
  In order to not having to log in every day
  As a lazy user
  I want downloads recognized automatically

  Scenario: recognize torrents in a directory
    Given a directory exists with path: "/media/torrents", watched: true
      And the following files exist on the filesystem:
        | path                            | source          |
        | /media/torrents/oneiric.torrent | oneiric.torrent |
        | /media/else/tatc.torrent        |                 |
     When the torrent syncer runs
     Then a torrent should exist with filename: "oneiric.torrent"

  @todo
  Scenario: recognize torrents somewhere (with mlocate)

  @todo
  Scenario: auto-fetch torrents for tv-shows
