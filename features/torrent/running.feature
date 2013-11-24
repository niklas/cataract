@javascript
Feature: Running torrents
  In order to know why my internet is so slow
  I want to see which torrents are currently running

  Scenario: just lookat them
    Given the following torrents exist:
      | title   | status   | url                  |
      | One     | running  |                      |
      | Another | running  |                      |
      | Two     | archived |                      |
      | Three   | remote   | http://local.torrent |
     And I am signed in
    When I go to the running list page
    Then the active nav item should be "Running"

    Then I should see the following torrents in the torrent list:
      | title   |
      | Another |
      | One     |
     And the window title should include "running torrents"
     But I should not see "Two"
     And I should not see "Three"

    When I filter with "ne"
     And the window title should include "running torrents containing 'ne'"
    Then I should see the following torrents in the torrent list:
      | title   |
      | One     |
     But I should not see "Another"
