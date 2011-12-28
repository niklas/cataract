@rootfs
Feature: Transfer info
  In order to see how the transfer is proceeding
  As a logged in user
  I want to see transfer rates and progress

  Background:
    Given a existing directory exists with path: "incoming"
      And a torrent_with_picture_of_tails exists with directory: the directory, content_directory: the directory
      And I am signed in

  @rtorrent
  Scenario Outline: rtorrent connection failing in different ways
    Given the file for the torrent exists
      And the torrent was refreshed
      And <scenario>
      And I am on the page for the torrent
     Then I should see "single" within the page title
     Then I should see the following attributes for the torrent:
        | content size | <size>     |
        | progress     | <progress> |
        | up rate      | <up>       |
        | down rate    | <down>     |

    Examples:
      | scenario                | size    | up          | down        | progress |
      | the torrent was started | 71.7 KB | 0 B/s       | 0 B/s       | 0%       |
      | nothing                 | 71.7 KB | not running | not running | 0%       |
      | rtorrent shuts down     | 71.7 KB | unavailable | unavailable | 0%       |


  Scenario: properly format values
    Given the file for the torrent exists
      And the torrent was refreshed
      And rtorrent list contains the following:
        | up_rate | down_rate | hash        |
        | 10      | 23000     | the torrent |
     When I go to the page for the torrent
     Then I should see the following attributes for the torrent:
        | up rate   | 10 B/s    |
        | down rate | 22.5 KB/s |

  Scenario: cache of catch-all will be cleared
    Given the file for the torrent exists
      And the torrent was refreshed
      And rtorrent list contains the following:
        | up_rate | hash        |
        | 5       | the torrent |
     When I go to the page for the torrent
     Then I should see the following attributes for the torrent:
        | up rate   | 5 B/s    |

    Given rtorrent list contains the following:
        | up_rate | hash        |
        | 23      | the torrent |
     When I go to the page for the torrent
     Then I should see the following attributes for the torrent:
        | up rate   | 23 B/s    |
