@fakefs
Feature: recognize torrents
  In order to not having to log in every day
  As a lazy user
  I want downloads recognized automatically

  Scenario: recognize torrents only in watched directories
    Given a directory exists with path: "/media/torrents", watched: true
      And a directory exists with path: "/media/else", watched: false
      And the following files exist on the filesystem:
        | path                            | source          |
        | /media/torrents/oneiric.torrent | oneiric.torrent |
        | /media/else/tatc.torrent        | natty.torrent   |
     When the torrent syncer runs
     Then a torrent should exist with filename: "oneiric.torrent"
      But 0 torrents should exist with filename: "natty.torrent"

  @todo
  Scenario: recognize torrents somewhere (with mlocate)

  @todo
  Scenario: auto-fetch torrents for tv-shows
