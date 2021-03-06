@rootfs
@rtorrent
@javascript
Feature: Adding a torrent

  Background:
    Given an existing directory exists with name: "Existing"
      And a directory "Incoming" exists with name: "Incoming"
      And the URL "http://hashcache.net/files/single.torrent" points to file "single.torrent"
      And I am signed in
      And I am on the list page

  Scenario: Adding by URL
     When I follow "Add"
      And I fill in "URL" with "http://hashcache.net/files/single.torrent"
      And I follow "Add" within the modal box
      And I wait for the spinner to stop
     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And the existing directory should be the torrent's content_directory
      And rtorrent should download the torrent

  Scenario: Adding by URL to specific directory
     When I follow "Add"
      And I fill in "URL" with "http://hashcache.net/files/single.torrent"
      And I select "Incoming" from "Content Directory"
      And I follow "Add" within the modal box
      And I wait for the spinner to stop
     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And the directory "Incoming" should be the torrent's content_directory
      And rtorrent should download the torrent

  Scenario: Upload with traditional multipart form
     When I follow "Add"
      And I attach the file "spec/factories/files/single.torrent" to "File"
      And I select "Incoming" from "Content Directory"
      And I follow "Add" within the modal box
      And I wait for the spinner to stop
     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And the directory "Incoming" should be the torrent's content_directory
      And rtorrent should download the torrent
     Then I should see the following torrents in the torrent list:
       | title  |
       | single |

  @todo
  @wip
  Scenario: Upload by dragging a file to the window

  @todo
  @wip
  Scenario: Upload by dragging a file to a directory
