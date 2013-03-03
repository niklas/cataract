@rootfs
@javascript
Feature: Transfer info
  In order to see how the transfer is proceeding
  As a logged in user
  I want to see transfer rates and progress

  Background:
    Given a existing directory exists with relative_path: "incoming"
      And a torrent_with_picture_of_tails exists with content_directory: the directory
      And I am signed in
      And the file for the torrent exists
      And the torrent's content exists on disk


  Scenario: properly format values
    Given rtorrent list contains the following:
        | up_rate | down_rate | hash        | active? | open? |
        | 10      | 23000     | the torrent | true    | true  |
      And the torrent is running
     When I go to the home page
      And I wait for the spinner to stop
     Then I should see the following torrents in the torrent list:
       | up        | down      |
       | 10 B/s    | 22.5 KB/s |

  Scenario: transfer data is not cached and updated on every tick
    Given the torrent is running
      And rtorrent list contains the following:
        | up_rate | hash        | active? | open? |
        | 5       | the torrent | true    | true  |
     When I go to the home page
      And I wait for the spinner to stop
     Then I should see the following torrents in the torrent list:
        | up      |
        | 5 B/s   |

    Given rtorrent list contains the following:
        | up_rate | hash        | active? | open? |
        | 23      | the torrent | true    | true  |
     When the tick interval is reached
     Then I should see the following torrents in the torrent list:
        | up      |
        | 23 B/s  |

  Scenario: progress pies updates themselfes
    Given the torrent is running
      And I am on the home page
      And I wait for the spinner to stop

     When rtorrent list contains the following:
        | down_rate | up_rate | size_bytes | completed_bytes | hash        | active? | open? |
        | 23        | 42      | 2000       | 300             | the torrent | true    | true  |
      And the tick interval is reached
     # size is taken from metadata
     Then I should see the following torrents in the torrent list:
        | up     | down   | percent | eta      |
        | 42 B/s | 23 B/s | 15%     | 1 minute |

     # stalled
     When rtorrent list contains the following:
        | down_rate | up_rate | size_bytes | completed_bytes | hash        | active? | open? |
        | 0         | 42      | 2000       | 301             | the torrent | true    | true  |
      And the tick interval is reached
     Then I should see the following torrents in the torrent list:
        | up     | down  | percent | eta               |
        | 42 B/s | 0 B/s | 15%     | when pigs can fly |

     # complete
     When rtorrent list contains the following:
        | down_rate | up_rate | size_bytes | completed_bytes | hash        | active? | open? |
        | 0         | 42      | 2000       | 2000            | the torrent | true    | true  |
      And the tick interval is reached
     Then I should see the following torrents in the torrent list:
        | up     | down  | percent | eta     |
        | 42 B/s | 0 B/s | 100%    | (i) nil |

  Scenario: stopped by someone else is detected
    Given the torrent is running
      And rtorrent list contains the following:
        | hash        | active? | open? |
        | the torrent | true    | true  |
      And I am on the home page
      And I wait for the spinner to stop
     When I explore the first torrent
     Then I should see the stop link

    Given rtorrent list contains the following:
        | hash |
      And the torrent is marked as archived
     When the tick interval is reached
     Then I should see the following torrents in the torrent list:
        | title  |
        | single |
     Then I should see the start link
      But I should not see the stop link
