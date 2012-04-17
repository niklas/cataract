@javascript
Feature: Paginate Torrents
  In order to find even very old torrents
  As a logged in user
  I want to page through all torrents

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
       | Unwanted  |
       | Number 05 |
       | Number 04 |
       | Number 03 |
       | Number 02 |
       | Number 01 |
      And I am signed in
      And I toggle the navigation
      And I follow "Torrents"
      And I filter the list with "Number"

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
