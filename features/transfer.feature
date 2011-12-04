Feature: Transferring torrents
  In order to download the contents of torrents
  As a logged in user
  I want to transfer torrents

  @todo
  Scenario: Start the transfer
    Given an archived torrent exists with title: "Ubuntu"
      And I am signed in
      And I am on the page of the torrent
     When I press "Start"
     Then I should see "Ubuntu"

  @todo
  Scenario: Pause the transfer

  @todo
  Scenario: Stop the transfer
