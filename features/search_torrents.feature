@javascript
Feature: Search torrents
  In order to find a torrent in less than 10 seconds
  As a logged in user
  I want to filter lists

  Background:
    Given the following archived torrents exist:
      | title |
      | One   |
      | Two   |
      | Three |
     And I am signed in
     And I follow "archived"

  Scenario: find by title
    Then I should see a list of the following torrents:
      | title |
      | Three |
      | Two   |
      | One   |

    When I filter the list with "one"
    Then I should see a list of the following torrents:
      | title |
      | One   |
