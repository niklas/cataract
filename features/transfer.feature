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

  Scenario: Start the transfer
    Given I am signed in
      And I am on the page for the torrent
     When I follow "Start"
     Then I should be on the page for the torrent
     #And I should see notice "started Tails"
      And the rtorrent main view should contain the torrent
      And rtorrent should download the torrent

  @todo
  @wip
  Scenario: Pause the transfer

  @todo
  @wip
  Scenario: Stop the transfer
