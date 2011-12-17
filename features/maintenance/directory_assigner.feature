@fakefs
Feature: Assigning directories
  In order to group torrents by their location on disk
  As a horder
  I want torrents assigned to the most specific directory

  Scenario: assign existing sub-directories, noting infixes for later compression
   Given the following filesystem structure exists on disk:
       | type | path                                                     |
       | file | /media/Serien/Tatort/Season23/Season23/Episode_5.mkv     |
       | file | /media/Serien/Lindenstr/Season77/Season77/Episode_66.mkv |
      # notice what a (missing) trailing ^^^^^^^ slash can make rsync do
     And the following directories exist:
       | directory | path                    |
       | Serien    | /media/Serien           |
       | Lindenstr | /media/Serien/Lindenstr |
       | Tatort    | /media/Serien/Tatort    |
     And the following torrents exist:
       | torrent | title  | content_path                     | content_directory |
       | T23x05  | T23x05 | /media/Serien/Tatort/Season23    |                   |
       | L77x66  | L77x66 | /media/Serien/Lindenstr/Season77 |                   |
    When the DirectoryAssigner runs
    Then 2 torrents should exist
     And the directory "Tatort" should be the torrent "T23x05"'s content_directory
     And the torrent "T23x05"'s content_path_infix should be "Season23"
     And the torrent "T23x05"'s content_path should be ""
     And the directory "Lindenstr" should be the torrent "L77x66"'s content_directory
     And the torrent "L77x66"'s content_path_infix should be "Season77"
     And the torrent "L77x66"'s content_path should be ""
     And the following filesystem structure should still exist on disk:
       | type | path                                                     |
       | file | /media/Serien/Tatort/Season23/Season23/Episode_5.mkv     |
       | file | /media/Serien/Lindenstr/Season77/Season77/Episode_66.mkv |

