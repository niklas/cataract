@javascript
@vcr
Feature: Feeds
  In order to always are up to date with my series
  As a series addict
  I want to download torrents automatically from RSS feeds

  Background:
    Given I am signed in
      And a feed exists with title: "EzRSS", url: "http://ezrss.it/feed/"
      And I am on the home page
      And all animations are disabled
      And I open the feeds menu

  Scenario: List feeds and look at contained torrents
    Given I should see the following feeds in a feed list:
       | title | url                   |
       | EzRSS | http://ezrss.it/feed/ |
     When I follow "EzRSS"
     Then I should see the following remote torrents in a remote torrent list:
      | title |
      | Foo   |
      | Bar   |
      | Baz   |


