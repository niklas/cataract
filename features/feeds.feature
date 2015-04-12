@javascript
@vcr
Feature: Feeds
  In order to always are up to date with my series
  As a series addict
  I want to download torrents automatically from RSS feeds

  Background:
    Given I am signed in
      And a feed exists with title: "KickAss", url: "https://kickass.to/usearch/user:eztv/?rss=1"
      And I am on the home page
      And all animations are disabled
      And I open the feeds menu

  Scenario: List feeds and look at contained torrents
    Given I should see the following feeds in a feed list:
       | title   | url                                         |
       | KickAss | https://kickass.to/usearch/user:eztv/?rss=1 |
     When I follow "KickAss"
     Then I should see the following remote torrents in a remote torrent list:
      | title               |
      | Cakes S06E25        |
      | Ow my Balls S23E44  |
      | Electophobia S01E02 |


