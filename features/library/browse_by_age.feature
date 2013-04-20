@javascript
Feature: Browse library by age
  In order to have a snappy frontpage but still can find all torrents
  I want to increase the age of torrents be shown

  Background:
    # FIXME can be removed when ember can distinguish between "empty" and "not loaded". #doh
    Given a directory exists

  Scenario: by age
      # more than one year ago
    Given today is 2011-12-31
      And a torrent exists with title: "Bones"
      # one year ago, more than a month
      And today is 2012-01-03
      And a torrent exists with title: "Rotten Beef"
      And today is 2012-11-31
      And a torrent exists with title: "Old Beef"
      # one month ago
      And today is 2012-12-03
      And a torrent exists with title: "Edible Beef"
      And today is 2012-12-31
      And a torrent exists with title: "Fresh Beef"

    Given today is 2013-01-01
      And I am signed in

     When I go to the recent list page
      And I wait for the spinner to stop
     Then I should see the following torrents in the torrent list:
      | title       |
      | Fresh Beef  |
      | Edible Beef |

     When I follow "in this month"
      And I follow "Year"
      And I wait for the spinner to stop
     Then I should see the following torrents in the torrent list:
      | title       |
      | Fresh Beef  |
      | Edible Beef |
      | Old Beef    |
      | Rotten Beef |

     When I follow "in this year"
      And I follow "All (slow)"
      And I wait for the spinner to stop
     Then I should see the following torrents in the torrent list:
      | title       |
      | Fresh Beef  |
      | Edible Beef |
      | Old Beef    |
      | Rotten Beef |
      | Bones       |

     When I follow "All since ever"
      And I follow "Month"
      And I wait for the spinner to stop
     Then I should see the following torrents in the torrent list:
      | title       |
      | Fresh Beef  |
      | Edible Beef |
