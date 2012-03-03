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

  Scenario: attributes
    Given a series exists with title: "Tatort"
      And a directory exists with name: "Angestaubt", path: "/an/ge/staubt"
      And a torrent exists with series: the series, title: "Unspannend 23"
      And I am signed in
     When I go to the page of the torrent
     Then I should see "Unspanned 23" within the page title
      And I should see "Tatort"
      And I should see "Angestaubt"
      And I should see "/an/ge/staubt"
