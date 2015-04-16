@javascript
@rootfs
Feature: Browsing the library
  In order to always know what I can watch, install or delete
  As a user
  I want to open the library to browse my finished downloads by their content location (directory and disk)

  Background:
    Given I am signed in
      And the following disks exist:
      | disk      | name      | path            |
      | Stuff     | Stuff     | media/Stuff     |
      | More      | More      | media/More      |
      | Removable | Removable | media/Removable |
      And the following disks are mounted:
      | disk         |
      | disk "Stuff" |
      | disk "More"  |
      And the following directories exist:
      | directory | disk             | name            | parent              | virtual | relative_path | show_sub_dirs |
      | Series    | disk "More"      | Series          |                     | true    | Serien        | true          |
      | MoviesM   | disk "More"      | Movies          |                     | true    |               | false         |
      | Frowns    | disk "More"      | Shame of Frowns | directory "Series"  | true    |               | false         |
      | Movies    | disk "Stuff"     | Movies          |                     | false   |               | false         |
      | SeriesR   | disk "Removable" | Series          |                     | true    | Serien        | true          |
      | FrownsR   | disk "Removable" | Shame of Frowns | directory "SeriesR" | true    |               | false         |
      | BallsR    | disk "Removable" | Oh my Balls     | directory "SeriesR" | true    |               | false         |

  Scenario: browsing around the filesystem
    Given I am on the home page

    # show root polies
     When I follow "Library"
     Then I should see a list of the following polies within the content:
       | name   |
       | Movies |
       | Series |

    # Stuff only has Movies
     When I follow "Stuff"
     Then I should see a list of the following directories within the content:
       | name   |
       | Movies |

    # More has both
     When I follow "More"
     Then I should see a list of the following directories within the content:
       | name   |
       | Movies |
       | Series |

    # Removable has only Series
     When I follow "Removable"
     Then I should see a list of the following directories within the content:
       | name   |
       | Series |

    # back to root polies
     When I follow "All"
     Then I should see a list of the following polies within the content:
       | name   |
       | Movies |
       | Series |

    # Only Stuff has Movies
     When I follow "Movies"
     Then I should see "Stuff" within the disks tab
      And I should see "More" within the disks tab
      But I should not see "Removable" within the disks tab
      And I should not see "Series" within the content

    # up a dir to roots
     When I follow "reset Directory" within the sidebar
     Then I should see a list of the following polies within the content:
       | name   |
       | Movies |
       | Series |

    # sub polies
     When I follow "Series"
     Then I should see a list of the following polies within the content:
       | name            |
       | Oh my Balls     |
       | Shame of Frowns |
      But I should not see "Stuff" within the disks tab

    # More has only on Series
     When I follow "More"
     Then I should see a list of the following directories within the content:
       | name            |
       | Shame of Frowns |

    # Removable has all Series
     When I follow "Removable"
     Then I should see a list of the following directories within the content:
       | name            |
       | Oh my Balls     |
       | Shame of Frowns |

    # Subsub dir does only exist on "Removable"
     When I follow "Oh my Balls"
     Then I should see "Removable" within the disks tab
      But I should not see "More" within the disks tab
      And I should not see "Stuff" within the disks tab

    # back to roots
     When I follow "reset Directory" within the sidebar
     Then I should see a list of the following polies within the content:
       | name   |
       | Movies |
       | Series |



  Scenario: torrents shown for directory ordered by something
    # TODO order by name ame
    # TODO how to display mount status on polys?
    Given the following torrents exist:
       | title             | content_directory   | updated_ago | payload_exists |
       | Medium Season     | directory "Frowns"  |             | true           |
       | Short Season      | directory "Frowns"  |             | true           |
       | Long Season       | directory "FrownsR" |             | true           |
       | Short Blockbuster | directory "Movies"  | 13 months   | true           |
       | Old Blockbuster   | directory "Movies"  | 13 months   | false          |
      And I am on the library page

     When I follow "Series" within the sidebar directory list
     Then I should not see "Season"
      And I should not see "Blockbuster"

    Given I should not see "Movies" within the sidebar directory list
     When I follow "all Directories"
     Then I should see "Movies" within the sidebar directory list

     When I follow "Movies" within the sidebar directory list
     Then I should see the following torrents in the torrent list:
      | title             |
      | Short Blockbuster |

     When I follow "Frowns" within the sidebar directory list
     Then I should see the following torrents in the torrent list:
      | title         |
      | Long Season   |
      | Short Season  |
      | Medium Season |
      But I should not see "Blockbuster"


     When I follow "Removable"
     Then I should see the following torrents in the torrent list:
      | title       |
      | Long Season |
      But I should not see "Blockbuster"

     When I follow "More"
     Then I should see the following torrents in the torrent list:
      | title         |
      | Short Season  |
      | Medium Season |
      But I should not see "Blockbuster"

     # filter searches only in directory
     When I filter with "Short"
     Then I should see the following torrents in the torrent list:
      | title        |
      | Short Season |
      But I should not see "Blockbuster"

    When I follow "reset Directory"
    Then I should see the following torrents in the torrent list:
      | title             |
      | Short Blockbuster |
      | Short Season      |

