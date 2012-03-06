@rootfs
Feature: Transfer info
  In order to see how the transfer is proceeding
  As a logged in user
  I want to see transfer rates and progress

  Background:
    Given a existing directory exists with path: "incoming"
      And a torrent_with_picture_of_tails exists with directory: the directory, content_directory: the directory
      And I am signed in
      And the file for the torrent exists
      And the torrent's content exists on disk

  @rtorrent
  Scenario Outline: rtorrent connection failing in different ways
    Given <scenario>
      And the torrent is marked as running
     When I go to the page for the torrent
     Then I should see "single" within the page title
      And I should see the following attributes for the torrent:
        | content      | <size>     |
        | progress     | <progress> |
        | up rate      | <up>       |
        | down rate    | <down>     |

    Examples:
      | scenario                | size    | up          | down        | progress    |
      | the torrent was started | 71.7 KB | 0 B/s       | 0 B/s       | 0%          |
      | nothing                 | 71.7 KB | not running | not running | not running |
      | rtorrent shuts down     | 71.7 KB | unavailable | unavailable | unavailable |


  Scenario: properly format values
    Given rtorrent list contains the following:
        | up_rate | down_rate | hash        |
        | 10      | 23000     | the torrent |
      And the torrent is running
     When I go to the page for the torrent
     Then I should see the following attributes for the torrent:
        | up rate   | 10 B/s    |
        | down rate | 22.5 KB/s |

  Scenario: cache of catch-all will be cleared
    Given the torrent is running
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

  @javascript
  Scenario: progress pie updates itself
    Given the torrent is running
      And I am on the page for the torrent
      And rtorrent list contains the following:
        | down_rate | up_rate | size_bytes | completed_bytes | hash        | active? |
        | 23        | 42      | 2000       | 300             | the torrent | true    |
     When the tick interval is reached
     Then I should see the following attributes for the torrent:
        | up rate   | 42 B/s |
        | down rate | 23 B/s |
        | progress  | 15%    |

  @javascript
  Scenario: stopped manually is detected
    Given the torrent is running
      And I am on the page for the torrent
      And rtorrent list contains the following:
        | hash |
      And I should see "Stop"
     When the tick interval is reached
     Then I should not see "Stop"
      But I should see "Start"
