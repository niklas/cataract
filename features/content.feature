Feature: Torrent content
  In order to manage free harddrive space
  As a user
  I want to manage torrent content

  @javascript
  Scenario: Move torrent
    Given a torrent with content exists with title: "Ubuntu"
      And a directory exists with path: "/some/where/very/public", name: nil
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

  @javascript
  @rootfs
  Scenario: clear a torrent's content
    Given a directory exists with path: "media/pics"
      And a torrent with picture of tails exists with content_directory: the directory
      And the torrent's content exists on disk
      And I am signed in
      And I am on the page for the torrent
     When I follow "Content"
      And I press "Clear"
     Then I should see flash notice "Freed 71.7 KB"
     Then the torrent's content should not exist on disk
