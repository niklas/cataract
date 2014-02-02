@javascript
@rtorrent
@vcr
Feature: Bookmarklet
  In order to download torrents comfortably
  As a signed in user
  I want to use a bookmarklet from a webpage


  Scenario: from torrentz.eu
    Given a existing directory exists
      And I am signed in
     When I use the scraping bookmarklet on the torrentz.eu page for Frankenstein 1931
      And I wait for the ok to appear in frame "cataract_new_scraping"
     Then I should see "Scraping" in frame "cataract_new_scraping"
      And I should see "following 'kickass.to'" in frame "cataract_new_scraping"
      And I should see "processing kickass.to" in frame "cataract_new_scraping"
      And I should see "following {:css" in frame "cataract_new_scraping"
      And I should see "processing torcache.net" in frame "cataract_new_scraping"
      And I should see "downloaded" in frame "cataract_new_scraping"
      And I should see "started" in frame "cataract_new_scraping"

      And a torrent should exist
      And the torrent should be running
