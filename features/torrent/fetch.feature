@rtorrent
@rootfs
@javascript
@vcr
Feature: Fetch torrent
  In order to start downloadling
  As a user
  I want to fetch a torrent by its url

  Scenario: Fetching successfully
    Given a remote torrent exists with url: "http://ubuntu.com/latest.iso.torrent"
      And a directory exists
      And I am signed in
      And I am on the recent list page
     When I explore the first torrent
      And I click on the start link
     Then I should see flash notice "started latest iso"
      And I should not see the start link
      And the torrent's info_hash should not be blank
      And the directory should be the torrent's content_directory
      And rtorrent should download the torrent
      And the rtorrent main view should contain the torrent
