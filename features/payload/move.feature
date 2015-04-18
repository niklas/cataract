@rootfs
@sse
@javascript
Feature: move content
  In order to use the space of all my harddrives effectivly
  I want to move torrent's content between directories and disks

  Background:
    Given a disk "incoming" exists with name: "Incoming"
      And a directory exists with relative_path: "pics", name: "Pics", disk: the disk, virtual: false
      And a torrent with picture of tails exists with content_directory: the directory, title: "Tails"
      And the torrent's content exists on disk
      And I am signed in

  Scenario: Move torrent on the same disk
    Given the following directories exist:
       | directory | name  | relative_path          | disk     | virtual |
       | Public    |       | some/where/very/public | the disk | false   |
       | Tails     | Tails | pics/of/tails          | the disk | false   |
       | Else      | Else  | some/where/else        | the disk | false   |
      And I am on the recent list page
     When I explore the first torrent
      And I click on the move link
      And I wait for the modal box to appear
     When I select "public" from "Directory"
      And I select "Incoming" from "Disk"
      And I press "Move" within the modal box
      And I wait for a flash notice to appear
     Then a move should exist
      And the torrent should be the move's torrent
      And the directory "Public" should be the move's target_directory
      And the disk should be the move's target_disk
      And I should see flash notice "moving Tails to Incoming / public"

     When I follow "1" within the queue
     Then I should see "moving Tails to Incoming / public" within the queue

     When the Move is worked on in background
     Then I should not see "1" within the queue
      And I should not see "moving" within the queue
      And I should see the following torrents in a torrent list:
        | title | content_directory_name | disk     |
        | Tails | public                 | Incoming |
      And the directory "Public" should be the torrent's content_directory

  #Scenario: Move torrent to other disk into existing directory

  Scenario: Move torrent to other disk into non-existing directory
    Given a disk "Archive" exists with name: "Archive"
      And I am on the recent list page
     When I explore the first torrent
      And I click on the move link
      And I wait for the modal box to appear
      # current Directory and Disk
     Then the selected "Directory" should be "Pics"
      And the selected "Disk" should be "Incoming"
     When I select "Archive" from "Disk"
      And I press "Move" within the modal box
      And I wait for a flash notice to appear
     Then a move should exist
      And the torrent should be the move's torrent
      And the directory should be the move's target_directory
      And the disk "Archive" should be the move's target_disk
      And I should see flash notice "moving Tails to Archive / Pics"

     When I follow "1" within the queue
     Then I should see "moving Tails to Archive / Pics" within the queue

     When the Move is worked on in background
     Then I should not see "1" within the queue
      And I should not see "moving" within the queue
      And I should see the following torrents in a torrent list:
      | title | content_directory_name | disk    |
      | Tails | Pics                   | Archive |
      And a directory "PicsArchive" should exist with name: "Pics", disk: the disk "Archive"
      And the directory "PicsArchive" should be the torrent's content_directory
