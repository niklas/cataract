@javascript
Feature: Browse library by age
  In order to have a snappy frontpage but still can find all torrents
  I want to increase the age of torrents be shown

  Background:
    # FIXME can be removed when ember can distinguish between "empty" and "not loaded". #doh
    Given a directory exists

  Scenario: by age
      # more than one year ago
    Given a torrent exists with title: "Bones", updated_ago: "13 months"

      # one year ago, more than a month
      And a torrent exists with title: "Rotten Beef", updated_ago: "11 months"
      And a torrent exists with title: "Old Beef", updated_ago: "40 days"

      # one month ago
      And a torrent exists with title: "Edible Beef", updated_ago: "28 days"
      And a torrent exists with title: "Fresh Beef", updated_ago: "1 days"

      And I am signed in

     When I go to the recent list page
      And I wait for the spinner to stop
     Then the active nav item should be "Recent"
      And I should see the following torrents in the torrent list:
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
