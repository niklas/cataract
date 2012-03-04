@javascript
Feature: refreshing a torrent
  In order to know the latest state of a torrent
  As a logged in user looking a the torrent
  I want the torrent to sync automatically on an ajax call

  Scenario: stopped manually is detected
    Given a running_torrent exists
      And I am signed in
      And I am on the page for the torrent
      And rtorrent list contains the following:
        | hash |
      And I should see "Stop"
     When the tick interval is reached
     Then I should not see "Stop"
      But I should see "Start"
