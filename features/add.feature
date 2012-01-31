@rootfs
@rtorrent
Feature: Adding a torrent

  Background:
    Given an existing directory exists

  Scenario: Adding by URL
    Given I am signed in
      And the URL "http://hashcache.net/files/single.torrent" points to "single.torrent"
     When I follow "Add"
      And I fill in "URL" with "http://hashcache.net/files/single.torrent"
      And I press "Add"
     Then I should see "Torrent was successfully created."
      And a torrent should exist
      And rtorrent should download the torrent

  @todo
  Scenario: Adding by Upload
