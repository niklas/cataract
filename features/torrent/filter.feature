@javascript
Feature: filter torrents
  In order to find a torrent in less than 10 seconds
  As a logged in user
  I want to filter torrents by status and text

  Background:
    Given the following torrents exist:
      | title | filename              | status   | url                  |
      | One   | doesntmatter1.torrent | running  |                      |
      | Two   | with_one_file.torrent | archived |                      |
      | Three | doesntmatter2.torrent | remote   | http://local.torrent |
     And I am signed in
     And I am on the recent list page

  Scenario: filter by entering text
    # match on title
    When I filter with "two"
    Then I should see the following torrents in the torrent list:
      | title |
      | Two   |

    # match on title or filename
    When I filter with "one"
    Then I should see the following torrents in the torrent list:
      | title |
      | Two   |
      | One   |
     And I should see "recent torrents containing 'one'" within the window title

    # match on substrings
    When I filter with "w"
    Then I should see the following torrents in the torrent list:
      | title |
      | Two   |

      # # TODO history management
      # When I toggle the menu
      #  And I follow "Library"
      #  And I go back
      # Then I should see the following torrents in the torrent list:
      #   | title |
      #   | Two   |
