@rootfs
@rtorrent
Feature: Adding a torrent

  Background:
    Given an existing directory exists with name: "Existing"
      And the URL "http://hashcache.net/files/single.torrent" points to file "single.torrent"
      And I am signed in
      And I am on the home page

  Scenario: Adding by URL
     When I follow "Add"
      And I fill in "URL" with "http://hashcache.net/files/single.torrent"
      And I press "Add"
     Then I should see "Torrent was successfully created."
      And a torrent should exist
      And the directory should be the torrent's content_directory
      And rtorrent should download the torrent

  Scenario: Adding by URL to specific directory
    Given a directory "Incoming" exists with name: "Incoming"
     When I follow "Add"
      And I fill in "URL" with "http://hashcache.net/files/single.torrent"
      And I select "Incoming" from "Content directory"
      And I press "Add"
     Then I should see "Torrent was successfully created."
      And a torrent should exist
      And the directory "Incoming" should be the torrent's content_directory
      And rtorrent should download the torrent

  Scenario: Upload with traditional multipart form
    Given a directory "Incoming" exists with name: "Incoming"
     When I follow "Add"
      And I attach the file "spec/factories/files/single.torrent" to "File"
      And I select "Incoming" from "Content directory"
      And I press "Add"
     Then I should see "Torrent was successfully created."
      And a torrent should exist
      And the directory "Incoming" should be the torrent's content_directory
      And rtorrent should download the torrent
      And I should see a table of the following torrents:
       | title  |
       | single |

