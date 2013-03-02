@rootfs
@javascript
Feature: move content
  In order to use the space of all my harddrives effectivly
  I want to move torrent's content between directories and disks

  Background:
    Given a disk "incoming" exists with name: "Incoming"
    And a directory exists with relative_path: "pics", name: "Pics", disk: the disk
      And a torrent with picture of tails exists with content_directory: the directory, title: "Tails"
      And the torrent's content exists on disk
      And I am signed in

  Scenario: Move torrent on the same disk
    Given the following directories exist:
       | directory | name  | relative_path          | disk     |
       | Public    |       | some/where/very/public | the disk |
       | Tails     | Tails | pics/of/tails          | the disk |
       | Else      | Else  | some/where/else        | the disk |
      And I am on the home page
     When I explore the first torrent
      And I click on the move link
      And I wait for the modal box to appear
     When I select "public" from "Directory"
      And I select "Incoming" from "Disk"
      And I follow "Move"
      And I wait for a flash notice to appear
     Then a move should exist
      And the torrent should be the move's torrent
      And the directory "Public" should be the move's target_directory
      And the disk should be the move's target_disk
      And I should see flash notice "moving Tails to Incoming / public"

     When I follow "1" within the queue
     Then I should see "moving Tails to Incoming / public" within the queue

  #Scenario: Move torrent to other disk into existing directory

  Scenario: Move torrent to other disk into non-existing directory
    Given a disk "archive" exists with name: "Archive"
      And I am on the home page
     When I explore the first torrent
      And I click on the move link
      And I wait for the modal box to appear
      # current Directory and Disk
     Then the selected "Directory" should be "Pics"
      And the selected "Disk" should be "Incoming"
     When I select "Archive" from "Disk"
      And I follow "Move"
      And I wait for a flash notice to appear
     Then a move should exist
      And the torrent should be the move's torrent
      And the directory should be the move's target_directory
      And the disk "archive" should be the move's target_disk
      And I should see flash notice "moving Tails to Archive / Pics"

     When I follow "1" within the queue
     Then I should see "moving Tails to Archive / Pics" within the queue

