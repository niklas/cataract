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
     Then I should be on the running list page
      And I should see a list of the following torrents:
       | title   |
       | Current |

     When I follow "Dashboard"
      And I follow "archived"
     Then I should be on the archived list page
      And I should see a list of the following torrents:
       | title |
       | Last  |

     When I follow "Last"
     Then I should be on the page for the archived torrent

     When I follow "archived" within the header
     Then I should be on the archived list page

     When I follow "Dashboard"
     Then I should see "Dashboard" within the header
      And I should be on the dashboard page

  Scenario: Paginate by endless page
    Given the following archived torrents exist:
       | title     |
       | Number 42 |
       | Number 41 |
       | Number 40 |
       | Number 39 |
       | Number 38 |
       | Number 37 |
       | Number 36 |
       | Number 35 |
       | Number 34 |
       | Number 33 |
       | Number 32 |
       | Number 31 |
       | Number 30 |
       | Number 29 |
       | Number 28 |
       | Number 27 |
       | Number 26 |
       | Number 25 |
       | Number 24 |
       | Number 23 |
       | Number 22 |
       | Number 21 |
       | Number 20 |
       | Number 19 |
       | Number 18 |
       | Number 17 |
       | Number 16 |
       | Number 15 |
       | Number 14 |
       | Number 13 |
       | Number 12 |
       | Number 11 |
       | Number 10 |
       | Number 09 |
       | Number 08 |
       | Number 07 |
       | Number 06 |
       | Number 05 |
       | Number 04 |
       | Number 03 |
       | Number 02 |
       | Number 01 |
      And I am signed in

     When I follow "archived"
     Then I should see a list of the following torrents:
       | title     |
       | Number 01 |
       | Number 02 |
       | Number 03 |
       | Number 04 |
       | Number 05 |
       | Number 06 |
       | Number 07 |
       | Number 08 |
       | Number 09 |
       | Number 10 |
       | Number 11 |
       | Number 12 |
       | Number 13 |
       | Number 14 |
       | Number 15 |
       | Number 16 |
       | Number 17 |
       | Number 18 |
       | Number 19 |
       | Number 20 |
      But I should not see "Number 21"

     When I scroll to the bottom
      And I wait for the spinner to stop
     Then I should see a list of the following torrents:
       | title     |
       | Number 01 |
       | Number 02 |
       | Number 03 |
       | Number 04 |
       | Number 05 |
       | Number 06 |
       | Number 07 |
       | Number 08 |
       | Number 09 |
       | Number 10 |
       | Number 11 |
       | Number 12 |
       | Number 13 |
       | Number 14 |
       | Number 15 |
       | Number 16 |
       | Number 17 |
       | Number 18 |
       | Number 19 |
       | Number 20 |
       | Number 21 |
       | Number 22 |
       | Number 23 |
       | Number 24 |
       | Number 25 |
       | Number 26 |
       | Number 27 |
       | Number 28 |
       | Number 29 |
       | Number 30 |
       | Number 31 |
       | Number 32 |
       | Number 33 |
       | Number 34 |
       | Number 35 |
       | Number 36 |
       | Number 37 |
       | Number 38 |
       | Number 39 |
       | Number 40 |
      But I should not see "Number 41"
      And I should not see "Number 42"

     # toggling should not reload items
     When I follow "Dashboard"
      And I follow "archived"
     Then I should see a list of the following torrents:
       | title     |
       | Number 01 |
       | Number 02 |
       | Number 03 |
       | Number 04 |
       | Number 05 |
       | Number 06 |
       | Number 07 |
       | Number 08 |
       | Number 09 |
       | Number 10 |
       | Number 11 |
       | Number 12 |
       | Number 13 |
       | Number 14 |
       | Number 15 |
       | Number 16 |
       | Number 17 |
       | Number 18 |
       | Number 19 |
       | Number 20 |
       | Number 21 |
       | Number 22 |
       | Number 23 |
       | Number 24 |
       | Number 25 |
       | Number 26 |
       | Number 27 |
       | Number 28 |
       | Number 29 |
       | Number 30 |
       | Number 31 |
       | Number 32 |
       | Number 33 |
       | Number 34 |
       | Number 35 |
       | Number 36 |
       | Number 37 |
       | Number 38 |
       | Number 39 |
       | Number 40 |
       | Number 41 |
       | Number 42 |
       # the last two items are fetched because the short dashboard causes the scroll event
