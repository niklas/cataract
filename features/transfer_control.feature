@rootfs
@rtorrent
@javascript
Feature: Transferring torrents
  In order to download the contents of torrents
  As a logged in user
  I want to transfer torrents

  Background:
    Given a existing directory exists with relative_path: "incoming"
      And a torrent_with_picture_of_tails exists with title: "Tails", content_directory: the directory
      And the file for the torrent exists
      And I am signed in

  Scenario: Start the transfer from the list
    Given I am on the home page
      And the tick interval is reached
     When I expand the first torrent
      And I click on the start link
      And I wait for the spinner to disappear
     Then I should see the stop link
      But I should not see the start link
      And the rtorrent main view should contain the torrent

  @todo
  @wip
  Scenario: Pause the transfer

  Scenario: detect torrent was started in the background
    Given I am on the home page
      And the tick interval is reached
      And the torrent was started
      And rtorrent should download the torrent
      And the tick interval is reached
     When I expand the first torrent
     Then I should see the stop link

  Scenario: Stop the transfer from the list
    Given the torrent was started
      And rtorrent should download the torrent
      And I am on the home page
      And the tick interval is reached
     When I expand the first torrent
      And I click on the stop link
      And I wait for the spinner to disappear
     Then I should see notice "stopped Tails"
      And I should be on the home page
      And I should not see the stop link
      And the rtorrent main view should not contain the torrent
