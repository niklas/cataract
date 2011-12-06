Feature: Torrent content
  In order to manage free harddrive space
  As a user
  I want to manage torrent content

  @javascript
  Scenario: Move torrent
    Given a torrent with content exists
      And a directory exists with name: "Archive"
      And I am signed in
      And I am on the page for the torrent
     When I follow "Move"
      And I select "Archive" from "Target"
      And I press "Move"
     Then a move job should exist

  @todo
  Scenario: Move torrent to another partition

  @todo
  Scenario: Move torrent within same partition

  @todo
  Scenario: clear a torrent's content
