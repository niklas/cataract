@javascript
@rootfs
Feature: Delete torrents
  In order to get rid of duplicates and accidently added torrents
  As a signed in user
  I want to delete a torrent

  Background:
    Given a disk exists with path: "usb"
      And a directory exists with relative_path: "pics", disk: the disk
      And a torrent with picture of tails exists with content_directory: the directory, title: "Tails"
      And the torrent's content exists on disk
     Then the file "usb/pics/tails.png" should exist on disk
      And I am signed in
      And I am on the home page
     When I click on the destroy link
      And I wait for the modal box to appear

  Scenario: Delete a torrent with its content
     When I check "delete content"
      And I press "delete"
      And I wait for the modal box to disappear
     Then I should see notice "Tails deleted"
      And I should not see "Tails" within the torrents list
      And the file "usb/pics/tails.png" should not exist on disk

  Scenario: Delete a torrent keeping its content
     When I uncheck "delete content"
      And I press "delete"
      And I wait for the modal box to disappear
     Then I should see notice "Tails deleted"
      And I should not see "Tails" within the torrents list
      And the file "usb/pics/tails.png" should exist on disk
