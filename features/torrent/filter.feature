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
     And I toggle the navigation
     And I follow "Torrents"

  Scenario: show recent first
    Then I should see a table of the following torrents:
      | title |
      | Three |
      | Two   |
      | One   |

  Scenario: filter by entering text
    # match on title
    When I filter with "two"
    Then I should see a table of the following torrents:
      | title |
      | Two   |

    # match on title or filename
    When I filter with "one"
    Then I should see a table of the following torrents:
      | title |
      | Two   |
      | One   |
     And I should see "all torrents containing 'one'" within the window title

    # match on substrings
    When I filter with "w"
    Then I should see a table of the following torrents:
      | title |
      | Two   |

    # history management
    When I follow "Two"
     And I go back
    Then I should see a table of the following torrents:
      | title |
      | Two   |

  Scenario: filter by selecting state
   Given "all" state should be chosen
     
    When I choose state "running"
    Then I should see a table of the following torrents:
      | title |
      | One   |
     And I should see "running torrents" within the window title
     
    When I choose state "archived"
    Then I should see a table of the following torrents:
      | title |
      | Two   |
     
    When I choose state "remote"
    Then I should see a table of the following torrents:
      | title |
      | Three   |
     And I should see "remote torrents" within the window title

    When I filter with "ee"
    Then I should see "remote torrents containing 'ee'" within the window title

