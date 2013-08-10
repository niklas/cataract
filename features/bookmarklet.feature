@javascript
Feature: Bookmarklet
  In order to download torrents comfortably
  As a signed in user
  I want to use a bookmarklet from a webpage


  Scenario: from torrentz.eu (frankenstein 1931)
    Given I am signed in
      And I am on the torrentz.eu page for Frankenstein 1931
     When I use the scraping bookmarklet
      And I wait for the ok to appear
     Then I should see "Scraping Torrentz... success"
      And I should see "Scraping kat.ph... success"
      And I should see "Downloading torrent... success"
      And I should see "Starting torrent... success"

      And a torrent should exist
      And the torrent should be running
