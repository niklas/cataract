@rootfs
Feature: Details of a torrent
  In order to know what's happening
  As a logged in user
  I want to view details of a torrent

  Scenario: attributes
    Given a series exists with title: "Lolcats"
      And a directory "I" exists with name: "Incoming", path: "/media/incoming"
      And a directory "A" exists with name: "Cat Pictures", path: "/media/pictures/cats"
      And a torrent_with_picture_of_tails exists with series: the series, title: "Rails", directory: directory "I", content_directory: directory "A"
      And the file for the torrent exists
      And I am signed in
     When I follow "Torrents"
      And I follow "Tails"
     Then I should be on the page of the torrent
     Then I should see "Rails" within the page title
      And I should see "Lolcats"
      And I should see "Cat Pictures"
      And I should see "/media/pictures/cats"
      And I should see "Incoming"
      And I should see "/media/incoming"
