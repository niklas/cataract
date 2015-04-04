@rootfs
@rtorrent
@javascript
Feature: Adding a torrent
  I want to add torrents and have them started automatically

  Background:
    Given an existing directory "Incoming" exists with name: "Incoming"
      And an existing directory "Another" exists with name: "Another"
      And a setting exists with incoming_directory: directory "Incoming"
      And the URL "http://hashcache.net/files/single.torrent" points to file "single.torrent"
      And I am signed in
      And I am on the running page

  Scenario: Adding by URL
     When I follow "Add"
      And I wait for the modal box to appear
     Then the selected "Content Directory" should be "Incoming"
     When I fill in "URL" with "http://hashcache.net/files/single.torrent"
      And I press "Add" within the modal box
      And I wait for the spinner to stop
     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And the existing directory "Incoming" should be the torrent's content_directory
      And rtorrent should download the torrent

  Scenario: Adding by URL to specific directory
     When I follow "Add"
      And I wait for the modal box to appear
      And I fill in "URL" with "http://hashcache.net/files/single.torrent"
      And I select "Another" from "Content Directory"
      And I press "Add" within the modal box
      And I wait for the spinner to stop
     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And the directory "Another" should be the torrent's content_directory
      And rtorrent should download the torrent
     When the tick interval is reached
     Then I should see the following torrents in the torrent list:
       | title  | percent | content_directory_name | payload_size |
       | single | 0%      | Another                | 71.7KiB      |
      And I should see the stop link

  Scenario: Upload with traditional multipart form
     When I follow "Add"
      And I attach the file "spec/factories/files/single.torrent" to "File"
      And I select "Incoming" from "Content Directory"
      And I press "Add" within the modal box
      And I wait for the spinner to stop

     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And rtorrent should download the torrent
     When the tick interval is reached
     Then I should see the following torrents in the torrent list:
       | title  | percent | content_directory_name | payload_size |
       | single | 0%      | Incoming               | 71.7KiB      |
      And I should see the stop link

  Scenario: Upload by dragging a file to the dropzone
     When I drag a file over the content
      And I wait for the modal box to appear
      And I drop file "spec/factories/files/single.torrent" onto the dropzone

     Then I should see flash notice "Torrent was successfully created."
      And a torrent should exist
      And rtorrent should download the torrent
     When the tick interval is reached
     Then I should see the following torrents in the torrent list:
       | title  | percent | content_directory_name | payload_size |
       | single | 0%      | Incoming               | 71.7KiB      |
      And I should see the stop link

  Scenario: Uploading a non-torrent
     When I drag a file over the content
     Then the dropzone should be classified as inviting
      But the dropzone should not be classified as hovered

     When I drag a file over the dropzone
     Then the dropzone should be classified as inviting
      And the dropzone should be classified as hovered

     When I drop file "spec/spec_helper.rb" onto the dropzone
     Then I should see flash alert "Could not create Torrent"
      And the dropzone should not be classified as inviting
      And the dropzone should not be classified as hovered


  @todo
  @wip
  Scenario: Upload by dragging a file to a directory
