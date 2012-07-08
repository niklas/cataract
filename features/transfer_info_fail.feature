@rtorrent
@64bit
@rootfs
Feature: Transfer info failure
  In order to see why my torrents are not downloading
  As a logged in user
  I want to see the reason for the failure

  Background:
    Given a existing directory exists with relative_path: "incoming"
      And a torrent_with_picture_of_tails exists with content_directory: the directory
      And I am signed in
      And the file for the torrent exists
      And the torrent's content exists on disk
      And the torrent is marked as running

  Scenario: torrent is not actually running
     When I go to the home page
     Then I should see the following torrents in the torrent list:
       | title  | size    | percent     | up          | down        |
       | single | 71.7 KB | not running | not running | not running |

  Scenario: rtorrent shuts down
    Given rtorrent shuts down
      And I wait 1 second
     When I go to the home page
     Then I should see the following torrents in the torrent list:
       | title  | size    | percent     | up          | down        |
       | single | 71.7 KB | unavailable | unavailable | unavailable |

