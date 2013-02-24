@javascript
Feature: Queue
  In order to know what's happening on the server
  As a user
  I want to see the queued and running actions in a queue

  Scenario: Pending moves are shown
    Given a torrent exists with title: "Shame of Bones"
      And a disk exists with name: "Archive"
      And a directory exists with name: "Adaptations"
      And a move exists with torrent: the torrent, target_disk: the disk, target_directory: the directory
      And I am signed in
      And I am on the home page
     Then I should see "1" within the queue
      And I should see "moving Shame of Bones to Archive / Adaptations" within the queue

  @todo
  Scenario: when a move is done, it is automatically removed from the list
    # tick? delete from JSON?
