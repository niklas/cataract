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
      | directory | disk         | name   |
      | Series    | disk "More"  | Series |
      | Movies    | disk "Stuff" | Movies |

  Scenario: accessible through the menu
     When I toggle the menu
      And I follow "Library"
      And I follow "Full Library"
     Then I should be on the library page
      And I should see a list of the following directories within the menu:
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

  Scenario: Browse root directories on disks
    Given I am on the library page
     When I follow "More" within the disk list
     Then I should be on the page for disk "More"
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
      And I should see a list of the following disks:
      | name  |
      | More  |
      | Stuff |
      And I should see a table of the following directories:
      | Name   |
      | Movies |
      But I should not see "Series" within the directories list
