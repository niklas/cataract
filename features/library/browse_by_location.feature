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


  Scenario: torrents shown for directory ordered by something
    # TODO order by name ame
    # TODO how to display mount status on polys?
    Given the following torrents exist:
       | title             | content_directory   |
       | Medium Season     | directory "Frowns"  |
       | Short Season      | directory "Frowns"  |
       | Long Season       | directory "FrownsR" |
       | Short Blockbuster | directory "Movies"  |
      And I am on the recent list page
      And I wait for the spinner to disappear

     When I follow "Series" within the sidebar directory list
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

