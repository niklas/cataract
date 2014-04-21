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
     When I go to the recent list page
      And I wait for the spinner to disappear

  Scenario: content directory is visible if torrent has content
    Given I should not see "Cat Pictures" within the torrents list
     When I explore the first torrent
     Then I should see the following attributes for the torrent:
        | content_directory | Cat Pictures    |
        | content_directory | pictures/cats   |
      And I should see "1 file"

  Scenario: click on filecount toggles filenames
    Given I should not see "tails.png"
     When I explore the first torrent
     Then I should not see "tails.png"
      And I follow "1 file"
     Then I should see "tails.png"
     # does not toggle whole torrent
      And I should see "Cat Pictures"

  Scenario: clear a torrent's content
     When I explore the first torrent
      And I click on the clear link
      And I follow "Clear"
      And I wait for a flash notice to appear
     Then I should see flash notice "Freed 71.7 KB"
      And I should be on the home page
      And the torrent's content should not exist on disk
      And I should not see the clear link
