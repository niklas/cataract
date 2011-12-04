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

     When I follow "running" within the footer
     Then I should see a list of the following torrents:
       | title   |
       | Current |
      And the button "running" should be active within the footer

      And I follow "archived" within the footer
     Then I should see a list of the following torrents:
       | title |
       | Last  |
      And the button "archived" should be active within the footer

     When I follow "Last"
     Then I should be on the page for the archived torrent
