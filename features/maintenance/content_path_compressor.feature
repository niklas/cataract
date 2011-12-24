@rootfs
Feature: compress content paths
  In order to find my way through 9001 gigaquods of pr0n
  As a horder
  I want to cleanup my filesystem


  Scenario: compresses infixes from directory-assigned torrents
    Given the following filesystem structure exists on disk:
       | type | path                                                    |
       | file | media/Serien/Tatort/Season23/Season23/Episode_5.mkv     |
       | file | media/Serien/Lindenstr/Season77/Season77/Episode_66.mkv |
      And the file "log/xbmc_updates.test.log" is deleted
     And the following directories exist:
       | directory | path                    |
       | Serien    | media/Serien           |
       | Lindenstr | media/Serien/Lindenstr |
       | Tatort    | media/Serien/Tatort    |
     And the following torrents exist:
       | torrent | title  | content_path_infix | content_filenames         | content_directory     |
       | T23x05  | T23x05 | Season23           | [Season23/Episode_5.mkv]  | directory "Tatort"    |
       | L77x66  | L77x66 | Season77           | [Season77/Episode_66.mkv] | directory "Lindenstr" |
    When the ContentPathCompressor runs
    Then the following filesystem structure should exist on disk:
       | type | path                                           |
       | file | media/Serien/Tatort/Season23/Episode_5.mkv     |
       | file | media/Serien/Lindenstr/Season77/Episode_66.mkv |
     But the following filesystem structure should be missing on disk:
       | type      | path                                                    |
       | file      | media/Serien/Tatort/Season23/Season23/Episode_5.mkv     |
       | directory | media/Serien/Tatort/Season23/Season23                   |
       | file      | media/Serien/Lindenstr/Season77/Season77/Episode_66.mkv |
       | directory | media/Serien/Lindenstr/Season77/Season77                |
    Then the directory "Tatort" should be the torrent "T23x05"'s content_directory
     And the torrent "T23x05"'s content_path should be ""
     And the torrent "T23x05"'s content_path_infix should be ""
     And the directory "Lindenstr" should be the torrent "L77x66"'s content_directory
     And the torrent "L77x66"'s content_path should be ""
     And the torrent "L77x66"'s content_path_infix should be ""
     And the file "log/xbmc_updates.test.log" should contain exactly:
       """
       UPDATE path SET strPath = replace(strPath, 'Season23/Season23', 'Season23') WHERE like('Season23/Season23', strPath);
       UPDATE path SET strPath = replace(strPath, 'Season77/Season77', 'Season77') WHERE like('Season77/Season77', strPath);

       """
