@rootfs
@javascript
Feature: Payload of a torrent
  In order to know how much space is wasted
  As a logged in user
  I want to inspect the payload of torrents

  Background:
    Given a series exists with title: "Lolcats"
      And a directory "A" exists with name: "Cat Pictures", relative_path: "pictures/cats"
      And a torrent_with_picture_of_tails exists with series: the series, title: "Tails", content_directory: directory "A"
      And the file for the torrent exists
      And the torrent's content exists on disk
      And I am signed in
      And I am on the recent list page

  Scenario: click on filecount toggles filenames
    Given I should see the following torrents in a torrent list:
      | title | content_directory_name | content_directory_path |
      | Tails | Cat Pictures           |                        |
      But I should not see "tails.png"
      And I should not see "1 file"
     When I explore the first torrent
     Then I should see "1 file"
     Then I should see the following torrents in a torrent list:
      | title | content_directory_name | content_directory_path |
      | Tails | Cat Pictures           | pictures/cats          |
      But I should not see "tails.png"
     When I press "1 file"
      And I should see "tails.png"

  Scenario: clear a torrent's content
     When I explore the first torrent
      And I click on the clear link
      And I press "Clear"
      And I wait for a flash notice to appear
     Then I should see flash notice "Freed 71.7 KB"
      And I should be on the home page
      And the torrent's content should not exist on disk
      And I should not see the clear link
