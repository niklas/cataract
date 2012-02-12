@javascript
Feature: Search torrents
  In order to find a torrent in less than 10 seconds
  As a logged in user
  I want to filter lists

  Background:
    Given the following archived torrents exist:
      | title | filename              |
      | One   | doesntmatter1.torrent |
      | Two   | with_one_file.torrent |
      | Three | doesntmatter2.torrent |
     And I am signed in
     And I follow "archived"

  Scenario: find by title
    When I filter the list with "two"
    Then I should see a list of the following torrents:
      | title |
      | Two   |

  Scenario: find by title or filename
    When I filter the list with "one"
    Then I should see a list of the following torrents:
      | title |
      | Two   |
      | One   |

  Scenario: find substrings
    When I filter the list with "w"
    Then I should see a list of the following torrents:
      | title |
      | Two   |
