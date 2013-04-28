@rootfs
@rtorrent
@javascript
Feature: Adding a torrent
  I want to add torrents and have them started automatically

  Background:
    Given an existing directory "Incoming" exists with name: "Incoming"
      And an existing directory exists with name: "Another"
      And a setting exists with incoming_directory: directory "Incoming"
      And the URL "http://hashcache.net/files/single.torrent" points to file "single.torrent"
      And I am signed in
      And I am on the list page

  Scenario: Adding by URL
     When I follow "Add"
      And I fill in "URL" with "http://hashcache.net/files/single.torrent"
      And I follow "Add" within the modal box
      And I wait for the spinner to stop
     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And the existing directory should be the torrent's content_directory
      And rtorrent should download the torrent

  Scenario: Adding by URL to specific directory
     When I follow "Add"
      And I fill in "URL" with "http://hashcache.net/files/single.torrent"
      And I select "Incoming" from "Content Directory"
      And I follow "Add" within the modal box
      And I wait for the spinner to stop
     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And the directory "Incoming" should be the torrent's content_directory
      And rtorrent should download the torrent

  Scenario: Upload with traditional multipart form
     When I follow "Add"
      And I attach the file "spec/factories/files/single.torrent" to "File"
      And I select "Incoming" from "Content Directory"
      And I follow "Add" within the modal box
      And I wait for the spinner to stop

     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And rtorrent should download the torrent
      And I should see "single" within the details
      And I should see "Incoming" within the details
      And I should see "71.7 KB" within the details
      And I should see the stop link
     Then I should see the following torrents in the torrent list:
       | title  | percent |
       | single | 0%      |

  Scenario: Upload by dragging a file to the dropzone
     When I drag a file over the dropzone
      And I drop file "spec/factories/files/single.torrent" onto the dropzone

     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And rtorrent should download the torrent
      And I should see "single" within the details
      And I should see "Incoming" within the details
      And I should see "71.7 KB" within the details
      And I should see the stop link
      And I should see the following torrents in the torrent list:
       | title  | percent |
       | single | 0%      |
      And the dropzone should not be classified as inviting
      And the dropzone should not be classified as hovered

  Scenario: Uploading a non-torrent
    Given the dropzone should not be classified as inviting
      And the dropzone should not be classified as hovered

     When I drag a file over the torrent list
     Then the dropzone should be classified as inviting
      But the dropzone should not be classified as hovered

     When I drag a file over the dropzone
     Then the dropzone should be classified as inviting
      And the dropzone should be classified as hovered

     When I drop file "spec/spec_helper.rb" onto the dropzone
     Then I should see flash alert "Could not create Torrent."
      And the dropzone should not be classified as inviting
      And the dropzone should not be classified as hovered


  @todo
  @wip
  Scenario: Upload by dragging a file to a directory
