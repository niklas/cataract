@javascript
@rootfs
Feature: Browsing the library
  In order to always know what I can watch, install or delete
  As a user
  I want to open the library to browse my finished downloads

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
      | directory | disk         | name            | parent             | auto_create | relative_path |
      | Series    | disk "More"  | Series          |                    |             | Serien        |
      | Movies    | disk "Stuff" | Movies          |                    | true        |               |
      | Frowns    | disk "More"  | Shame of Frowns | directory "Series" |             |               |

  Scenario: disks and root directories directly accessible through the sidebar
    Given I am on the home page
      And I wait for the spinner to disappear
     Then I should see the following mounted disks in the sidebar disk list:
      | name  |
      | More  |
      | Stuff |
      And I should see the following unmounted disks in the sidebar disk list:
      | name      |
      | Removable |
      And I should see the following existing directories in the sidebar directory list:
      | Name   |
      | Movies |
      And I should see the following missing directories in the sidebar directory list:
      | Name   |
      | Series |

  Scenario: Browse to root directories on disks
    Given I am on the library page
     When I follow "More" within the sidebar disk list
     Then I should be on the page for disk "More"
      And I should see the following breadcrumbs:
      | More |
      And I should see the following mounted disks in the sidebar disk list:
      | name  |
      | More  |
      | Stuff |
      And I should see a table of the following directories:
      | Name   |
      | Series |
      But I should not see "Movies" within the directories list

     When I follow "Stuff" within the sidebar disk list
     Then I should be on the page for disk "Stuff"
      And I should see the following breadcrumbs:
      | Stuff |
      And I should see the following mounted disks in the sidebar disk list:
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

   Scenario: alternate between copies of directories based on common relative_path
     Given a disk "Incoming" exists with name: "Incoming"
       And a directory "Incoming Series" exists with name: "Series", disk: disk "Incoming", relative_path: "Serien"
      When I go to the page for the directory "Series"
      Then I should see the following breadcrumbs:
        | More / |
        | Series |
        | Edit   |
      When I follow "More" within the breadcrumbs
       And I follow "Incoming" within the breadcrumbs
      Then I should be on the page for the directory "Incoming Series"
      Then I should see the following breadcrumbs:
        | Incoming / |
        | Series     |
        | Edit       |



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
    Then I should see the following torrents in the torrent list:
      | title             |
      | Short Blockbuster |

     When I go to the page for the directory "Frowns"
    Then I should see the following torrents in the torrent list:
      | title        |
      | Long Season  |
      | Short Season |
      But I should not see "Blockbuster"

     # filter searches only in directory
     When I filter with "Short"
    Then I should see the following torrents in the torrent list:
      | title             |
      | Short Season      |
      But I should not see "Long"
      And I should not see "Blockbuster"

