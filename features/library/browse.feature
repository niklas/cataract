@javascript
Feature: Browsing the library
  In order to always know what I can watch, install or delete
  As a user
  I want to open the library to browse my finished downloads

  Background:
    Given I am signed in
      And the following disks exist:
      | disk  | name  |
      | Stuff | Stuff |
      | More  | More  |
      And the following directories exist:
      | directory | disk         | name            | parent             |
      | Series    | disk "More"  | Series          |                    |
      | Movies    | disk "Stuff" | Movies          |                    |
      | Frowns    | disk "More"  | Shame of Frowns | directory "Series" |

  Scenario: directories directly accessible through the sidebar
    Given I am on the home page
     When I toggle the menu
      And I follow "Library"
     Then I should be on the library page
      And I should see a list of the following directories within the sidebar:
      | name   |
      | Movies |
      | Series |
      And I should see a list of the following disks:
      | name  |
      | More  |
      | Stuff |
      And I should see a table of the following directories:
      | Name   |
      | Movies |
      | Series |

  Scenario: Browse to root directories on disks
    Given I am on the library page
     When I follow "More" within the disk list
     Then I should be on the page for disk "More"
      And I should see the following breadcrumbs:
      | More |
      And I should see a list of the following disks:
      | name  |
      | More  |
      | Stuff |
      And I should see a table of the following directories:
      | Name   |
      | Series |
      But I should not see "Movies" within the directories list

     When I follow "Stuff" within the disk list
     Then I should be on the page for disk "Stuff"
      And I should see the following breadcrumbs:
      | Stuff |
      And I should see a list of the following disks:
      | name  |
      | More  |
      | Stuff |
      And I should see a table of the following directories:
      | Name   |
      | Movies |
      But I should not see "Series" within the directories list

   Scenario: Browse to subdirectories
    Given I am on the page for disk "More"
     When I follow "Series" within the directories list
     Then I should be on the page for the directory "Series"
      And I should see the following breadcrumbs:
      | More / |
      | Series |
      | Edit   |
     When I follow "Shame of Frowns" within the directories list
     Then I should be on the page for the directory "Frowns"
      And I should see the following breadcrumbs:
      | More /          |
      | Series /        |
      | Shame of Frowns |
      | Edit            |

   Scenario: torrents shown for directory ordered by name
    Given the following torrents exist:
       | title             | content_directory  |
       | Short Season      | directory "Frowns" |
       | Long Season       | directory "Frowns" |
       | Short Blockbuster | directory "Movies" |

     When I go to the page for the directory "Series"
     Then I should not see "Season"
      And I should not see "Blockbuster"

     When I go to the page for the directory "Movies"
     Then I should see a table of the following torrents:
      | title             |
      | Short Blockbuster |

     When I go to the page for the directory "Frowns"
     Then I should see a table of the following torrents:
      | title        |
      | Long Season  |
      | Short Season |
      But I should not see "Blockbuster"

     # filter searches only in directory
     When I filter with "Short"
     Then I should see a table of the following torrents:
      | title             |
      | Short Season      |
      But I should not see "Long"
      And I should not see "Blockbuster"

