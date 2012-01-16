@rootfs
Feature: Adding a torrent

  Background:
    Given an existing directory exists

  Scenario: Adding by URL
    Given I am signed in
     When I follow "Add"
      And I fill in "URL" with "http://localhost:1337/files/single.torrent"
      And I press "Add"
     Then I should see "Torrent was successfully created."
      And a torrent should exist
      And rtorrent should download the torrent

  @todo
  Scenario: Adding by Upload
