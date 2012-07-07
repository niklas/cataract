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
      And I am on the home page

  Scenario: Start the transfer form the list
     When I click on the start link
     Then I should see a stop link
      But I should not see a start link
      And the rtorrent main view should contain the torrent

  Scenario: Start the transfer from the page of the torrent
    Given I am on the page for the torrent
     When I follow "Start"
     Then I should be on the page for the torrent
     #And I should see notice "started Tails"
      And I should see no link "Start"
      And rtorrent should download the torrent
      And the rtorrent main view should contain the torrent

  @todo
  @wip
  Scenario: Pause the transfer

  Scenario: Stop the transfer
    Given the torrent was started
      And rtorrent should download the torrent
      And I am on the page for the torrent
     When I follow "Stop"
     Then I should be on the page for the torrent
      And I should see no link "Stop"
      And the rtorrent main view should not contain the torrent
