Feature: Browse Torrents
  In order to find and control my downloads
  As a logged in user
  I want to browse torrents

  Scenario: displays filename
    Given the following torrents exist:
      | filename              |
      | Ubuntu-ozelot.torrent |
      And I am signed in
     Then I should see a list of the following torrents:
       | filename              |
       | Ubuntu-ozelot.torrent |
