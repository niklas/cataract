@rootfs
@rtorrent
@javascript
Feature: Transferring torrents
  In order to download the contents of torrents
  As a logged in user
  I want to transfer torrents

  Background:
    Given a existing directory exists with path: "incoming"
      And a torrent_with_picture_of_tails exists with title: "Tails", directory: the directory, content_directory: the directory
      And the file for the torrent exists
      And I am signed in

  Scenario: Start the transfer
    Given I am on the page for the torrent
     When I follow "Start"
     Then I should be on the page for the torrent
     #And I should see notice "started Tails"
      And the rtorrent main view should contain the torrent
      And rtorrent should download the torrent

  @todo
  @wip
  Scenario: Pause the transfer

  Scenario: Stop the transfer
    Given the torrent was started
      And I am on the page for the torrent
     When I follow "Stop"
     Then I should be on the page for the torrent
      And the rtorrent main view should not contain the torrent
