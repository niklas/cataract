@javascript
Feature: Recent torrents
  In order to find something to watch next
  I want to see a list of new torrents

  Scenario: Scrolling through by endless page
    Given the following archived torrents exist:
       | title     |
       | Number 59 |
       | Number 58 |
       | Number 57 |
       | Number 56 |
       | Number 55 |
       | Number 54 |
       | Number 53 |
       | Number 52 |
       | Number 51 |
       | Number 50 |
       | Number 49 |
       | Number 48 |
       | Number 47 |
       | Number 46 |
       | Number 45 |
       | Number 44 |
       | Number 43 |
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
       | Unwanted  |
       | Number 05 |
       | Number 04 |
       | Number 03 |
       | Number 02 |
       | Number 01 |
      And I am signed in
      And I am on the home page

     # And "Recent" should be active
     When I filter with "Number"

     Then I should see the following torrents in the torrent list:
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
       | Number 43 |
       | Number 44 |
       | Number 45 |
       | Number 46 |
       | Number 47 |
       | Number 48 |
       | Number 49 |
       | Number 50 |
      But I should not see "Number 51"

     When I scroll to the bottom
      And I wait for the spinner to stop
     Then I should see the following torrents in the torrent list:
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
       | Number 43 |
       | Number 44 |
       | Number 45 |
       | Number 46 |
       | Number 47 |
       | Number 48 |
       | Number 49 |
       | Number 50 |
       | Number 51 |
       | Number 52 |
       | Number 53 |
       | Number 54 |
       | Number 55 |
       | Number 56 |
       | Number 57 |
       | Number 58 |
       | Number 59 |
