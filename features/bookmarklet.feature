@javascript
Feature: Bookmarklet
  In order to download torrents comfortably
  As a signed in user
  I want to use a bookmarklet from a webpage


  Scenario: from torrentz.eu
    Given I am signed in
     When I use the scraping bookmarklet on the torrentz.eu page for Frankenstein 1931
      And I wait for the ok to appear
     Then I should see "Scraping" within "#cataract_new_scraping"
      And I should see "Scraping kat.ph... success" within "#cataract_new_scraping"
      And I should see "Downloading torrent... success" within "#cataract_new_scraping"
      And I should see "Starting torrent... success" within "#cataract_new_scraping"

      And a torrent should exist
      And the torrent should be running
