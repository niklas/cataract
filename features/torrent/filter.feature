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
    Then I should see a list of the following torrents:
      | title |
      | Three |
      | Two   |
      | One   |

  Scenario: filter by entering text
    # match on title
    When I filter the list with "two"
    Then I should see a list of the following torrents:
      | title |
      | Two   |

    # match on title or filename
    When I filter the list with "one"
    Then I should see a list of the following torrents:
      | title |
      | Two   |
      | One   |

    # match on substrings
    When I filter the list with "w"
    Then I should see a list of the following torrents:
      | title |
      | Two   |

  Scenario: filter by selecting state
   Given "all" state should be chosen
     
    When I choose state "running"
    Then I should see a list of the following torrents:
      | title |
      | One   |
     
    When I choose state "archived"
    Then I should see a list of the following torrents:
      | title |
      | Two   |
     
    When I choose state "remote"
    Then I should see a list of the following torrents:
      | title |
      | Three   |


