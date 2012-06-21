@rootfs
@javascript
Feature: Details of a torrent
  In order to know what's happening
  As a logged in user
  I want to view details of a torrent

  Scenario: attributes
    Given a series exists with title: "Lolcats"
      And a directory "A" exists with name: "Cat Pictures", relative_path: "pictures/cats"
      And a torrent_with_picture_of_tails exists with series: the series, title: "Tails", content_directory: directory "A"
      And the file for the torrent exists
      And the torrent's content exists on disk
      And I am signed in
      And I am on the home page
     When I follow "Tails"
     Then I should be on the page of the torrent
      And I should see "Tails" within the page title
      And I should see the following attributes for the torrent:
        | series            | Lolcats         |
        | content_directory | Cat Pictures    |
        | content_directory | pictures/cats   |
