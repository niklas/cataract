Feature: Torrent content
  In order to manage free harddrive space
  As a user
  I want to manage torrent content

  @javascript
  Scenario: Move torrent
    Given a torrent with content exists with title: "Ubuntu"
      And a directory exists with name: "Public"
      And I am signed in
      And I am on the page for the torrent
     When I follow "Move"
      And I select "Public" from "Target"
      And I press "Move"
     Then a move should exist
      And the torrent should be the move's torrent
      And the directory should be the move's target
      And I should see "moving Ubuntu to Public"

  @todo
  Scenario: Move torrent to another partition

  @todo
  Scenario: Move torrent within same partition

  @todo
  Scenario: clear a torrent's content
