@rootfs
@javascript
Feature: Torrent content
  In order to manage free harddrive space
  As a user
  I want to manage torrent content

  Background:
    Given a directory exists with path: "media/pics"
      And a torrent with picture of tails exists with content_directory: the directory, title: "Tails"
      And the torrent's content exists on disk
      And I am signed in
      And I am on the page for the torrent

  Scenario: Move torrent
    Given the following directories exist:
       | directory | name  | path                    |
       | Public    |       | /some/where/very/public |
       | Tails     | Tails | /pics/of/tails          |
       | Else      | Else  | /some/where/else        |
     When I follow "Move"
      And I wait for the modal box to appear
     Then the selected "Target" should be "Tails"
      And I select "public" from "Target"
      And I press "Move"
      And I wait for the modal box to disappear
      And I wait for a flash notice to appear
     Then a move should exist
      And the torrent should be the move's torrent
      And the directory "Public" should be the move's target
      And I should see flash notice "moving Tails to public"
      And I should be on the page for the torrent

  Scenario: clear a torrent's content
     When I follow "Clear" within the content section
      And I confirm popup
      And I wait for a flash notice to appear
     Then I should see flash notice "Freed 71.7 KB"
      And I should be on the page for the torrent
      And the torrent's content should not exist on disk
