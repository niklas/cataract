@fakefs
Feature: create subdirectories
  In order to assign TVshows to their own folder
  As a horder
  I want the subdirectories to be found an created

  Scenario: auto-create sub-directories from fs to db
    Given a disk exists with path: "/media"
      And the following directories exist:
       | relative_path | show_sub_dirs | disk     |
       | Serien        | true          | the disk |
      And the following filesystem structure exists on disk:
       | type      | path                 |
       | directory | /media/Serien/Show 1 |
       | directory | /media/Serien/Show 2 |
       | directory | /media/Serien/Show 3 |
      And 1 directories should exist
     When the SubDirectoryCreator runs
     Then 4 directories should exist
      And the following directories should exist:
       | relative_path | show_sub_dirs |
       | Serien        | true          |
       | Serien/Show 1 | false         |
       | Serien/Show 2 | false         |
       | Serien/Show 3 | false         |

