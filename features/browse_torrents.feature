@javascript
Feature: Browse Torrents
  In order to find and control my downloads
  As a logged in user
  I want to browse torrents

  # TODO must select status
  @wip
  Scenario: displays filename and title
    Given the following torrents exist:
      | filename              | title  |
      | Ubuntu-ozelot.torrent | Ozelot |
      And I am signed in
     Then I should see a list of the following torrents:
       | filename              | title  |
       | Ubuntu-ozelot.torrent | Ozelot |

  Scenario: Filter by status
    Given a remote torrent exists with title: "Next"
      And a running torrent exists with title: "Current"
      And an archived torrent exists with title: "Last"
      And I am signed in

     When I follow "running"
     Then I should see a list of the following torrents:
       | title   |
       | Current |
      And I should see "running" within the header

     When I follow "Back"
      And I follow "archived"
     Then I should see a list of the following torrents:
       | title |
       | Last  |
      And I should see "archived" within the header
