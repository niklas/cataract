@fakefs
Feature: create subdirectories
  In order to assign TVshows to their own folder
  As a horder
  I want the subdirectories to be found an created

  Scenario: auto-create sub-directories from fs to db
    Given the following directories exist:
       | path          | show_sub_dirs |
       | /media/Serien | true          |
      And the following filesystem structure exists on disk:
       | type      | path                 |
       | directory | /media/Serien/Show 1 |
       | directory | /media/Serien/Show 2 |
       | directory | /media/Serien/Show 3 |
    When the SubDirectoryCreator runs
     Then the following directories should exist:
       | path                 | show_sub_dirs |
       | /media/Serien        | true          |
       | /media/Serien/Show 1 | false         |
       | /media/Serien/Show 2 | false         |
       | /media/Serien/Show 3 | false         |

