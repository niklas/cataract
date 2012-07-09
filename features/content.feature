@rootfs
@javascript
Feature: Torrent content
  In order to manage free harddrive space
  As a user
  I want to manage torrent content

  Background:
    Given a directory exists with relative_path: "pics"
      And a torrent with picture of tails exists with content_directory: the directory, title: "Tails"
      And the torrent's content exists on disk
      And I am signed in
      And I am on the home page

  Scenario: clear a torrent's content
     When I click on the clear link
      And I confirm popup
      And I wait for a flash notice to appear
     Then I should see flash notice "Freed 71.7 KB"
      And I should be on the home page
      And the torrent's content should not exist on disk
      And I should not see a clear link
