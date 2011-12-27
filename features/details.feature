Feature: Details of a torrent
  In order to know what's happening
  As a logged in user
  I want to view details of a torrent


  Scenario: browsing to the torrent
    Given a running torrent exists with title: "Ubuntu"
      And I am signed in
     When I follow "running"
      And I follow "Ubuntu"
     Then I should be on the page of the torrent

  Scenario: static attributes
    Given a running torrent exists with title: "Ubuntu"
      And I am signed in
      And I am on the page of the torrent
     Then I should see "Ubuntu" within the page title
