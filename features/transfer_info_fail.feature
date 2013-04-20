@javascript
@64bit
@rootfs
Feature: Transfer info failure
  In order to see why my torrents are not downloading
  As a logged in user
  I want to see the reason for the failure

  Background:
    Given a existing directory exists with relative_path: "incoming"
      And a torrent_with_picture_of_tails exists with content_directory: the directory, title: "Tails"
      And I am signed in
      And the file for the torrent exists
      And the torrent's content exists on disk

  @rtorrent
  Scenario: torrent is not actually running
    Given the torrent was started
      And rtorrent should download the torrent
      And I am on the running list page
      And I should see "Tails"

     When the tick interval is reached
      And I wait for the spinner to disappear
     Then I should see "Tails"

     When the torrent was stopped
      And the tick interval is reached
      And I wait for the spinner to disappear
     Then I should not see "Tails"

     When I go to the recent list page
     Then I should see "Tails"

     When I explore the first torrent
     Then I should see the start link

  Scenario: rtorrent is not started
    Given I am on the home page
     When the tick interval is reached
      And I wait for the spinner to disappear
     Then I should see "Connection to rtorrent refused"

