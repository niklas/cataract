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
      | SeriesR   | disk "Removable" | Series          |                     | true    | Serien        | true          |
      | Movies    | disk "Stuff"     | Movies          |                     | false   |               | false         |
      | Frowns    | disk "More"      | Shame of Frowns | directory "Series"  | true    |               | false         |
      | FrownsR   | disk "Removable" | Shame of Frowns | directory "SeriesR" | true    |               | false         |

  # Hhow to display mount status on polys?
  @wip
  Scenario: directories directly accessible through the sidebar
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

  @wip
  Scenario: Selecting a disk shows only *its* root directories in sidebar
     When I follow "More" within the sidebar disk list
      Then I should see the following active disks in the sidebar disk list:
      | name  |
      | More  |
      And I should see the following mounted disks in the sidebar disk list:
      | name  |
      | More  |
      | Stuff |
      And I should see the following directories in the sidebar root directory list:
      | Name   |
      | Series |
      But I should not see "Movies" within the sidebar root directory list

     When I follow "Stuff" within the sidebar disk list
      Then I should see the following active disks in the sidebar disk list:
      | name  |
      | Stuff  |
      And I should see the following mounted disks in the sidebar disk list:
      | name  |
      | More  |
      | Stuff |
      And I should see the following directories in the sidebar root directory list:
      | Name   |
      | Movies |
      But I should not see "Series" within the sidebar root directory list



   @wip
   Scenario: Browse to subdirectories
    Given a torrent exists with content_directory: directory "Frowns", title: "First Shame"
      And I am on the recent list page
      And I wait for the spinner to disappear
     When I follow "Series" within the sidebar root directory list
     Then I should not see "First Shame"
     When I follow "Shame of Frowns" within the directories list
     Then I should see the following torrents in the torrent list:
      | title       |
      | First Shame |

  @wip
   Scenario: alternate between copies of directories based on common relative_path
    Given a disk "Incoming" exists with name: "Incoming"
      And a directory "Incoming Series" exists with name: "Series", disk: disk "Incoming", relative_path: "Serien"
      And I am on the home page
      And I wait for the spinner to disappear
      When I follow "Series"
      Then I should see the following breadcrumbs:
        | More / |
        | Series |
        | Edit   |
      When I follow "More" within the breadcrumbs
       And I follow "Incoming" within the breadcrumbs
      Then I should see the following breadcrumbs:
        | Incoming / |
        | Series     |
        | Edit       |



   Scenario: torrents shown for directory ordered by name
    Given the following torrents exist:
       | title             | content_directory   |
       | Medium Season     | directory "Frowns"  |
       | Short Season      | directory "Frowns"  |
       | Long Season       | directory "FrownsR" |
       | Short Blockbuster | directory "Movies"  |
      And I am on the recent list page
      And I wait for the spinner to disappear

     When I follow "Serien" within the sidebar directory list
     Then I should not see "Season"
      And I should not see "Blockbuster"

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

     When I follow "Removable" within the disks tab
     Then I should see the following torrents in the torrent list:
      | title       |
      | Long Season |
      But I should not see "Blockbuster"

     When I follow "More" within the disks tab
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

