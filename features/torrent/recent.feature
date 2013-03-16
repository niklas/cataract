@javascript
Feature: Recent torrents, paginated
  In order to find something to watch next
  I want to see a list of recent torrents

  Scenario: Paginating through more than 50 torrents
    Given archived torrents exist titled from "Number 01" to "Number 52" in reverse chronological order
      And an archived torrent exists with title: "Unwanted"
      And I am signed in
      And I am on the home page

     When I filter with "Number"
     Then I should see the torrents titled from "Number 01" to "Number 50"
      But I should not see "Number 51"
      And I should not see "Number 52"

     When I follow "next"
     Then I should see the torrents titled from "Number 51" to "Number 52"
