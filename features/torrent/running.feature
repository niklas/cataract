@javascript
Feature: Running torrents
  In order to know why my internet is so slow
  I want to see which torrents are currently running

  Scenario: just lookat them
    Given the following torrents exist:
      | title | status   | url                  |
      | One   | running  |                      |
      | Two   | archived |                      |
      | Three | remote   | http://local.torrent |
     And I am signed in
     And I am on the home page

    When I toggle the menu
     And I follow "Running"
    Then I should see a table of the following torrents:
      | title |
      | One   |
     And I should see "running torrents" within the window title
     But I should not see "Two"
     And I should not see "Three"

    When I filter with "ne"
    Then I should see "running torrents containing 'ne'" within the window title
