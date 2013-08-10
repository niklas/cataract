Feature: Bookmarklet
  In order to download torrents comfortably
  As a signed in user
  I want to use a bookmarklet from a webpage


  Scenario: from torrentz.eu (frankenstein 1931)
    Given I am signed in
     When I use the bookmarklet on "http://torrentz.eu/dcc5fba0c3bbb3fc155df8e96736e6e5bc207287"
      And I wait for the checkmark to appear
     Then I should see "Scraping Torrentz... success"
      And I should see "Scraping kat.ph... success"
      And I should see "Downloading torrent... success"
      And I should see "Starting torrent... success"

      And a torrent should exist
      And the torrent should be running
