@javascript
@64bit
@rootfs
Feature: Transfer info failure
  In order to see why my torrents are not downloading
  As a logged in user
  I want to see the reason for the failure

  Background:
    Given a existing directory exists with relative_path: "incoming"
      And a torrent_with_picture_of_tails exists with content_directory: the directory
      And I am signed in
      And the file for the torrent exists
      And the torrent's content exists on disk
      And the torrent is marked as running
      And I am on the home page

  @rtorrent
  Scenario: torrent is not actually running
     When the tick interval is reached
      And I wait for the spinner to disappear
      And I click on the first torrent
     Then I should see the start link

  Scenario: rtorrent is not started
     When the tick interval is reached
      And I wait for the spinner to disappear
     Then I should see "Connection to rtorrent refused" within the first torrent

