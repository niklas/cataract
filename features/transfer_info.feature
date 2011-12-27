@rootfs
Feature: Transfer info
  In order to see how the transfer is proceeding
  As a logged in user
  I want to see transfer rates and progress

  @rtorrent
  Scenario Outline:
    Given a existing directory exists with path: "incoming"
      And a torrent_with_picture_of_tails exists with directory: the directory, content_directory: the directory
      And the file for the torrent exists
      And the torrent was refreshed
      And <scenario>
      And I am signed in
      And I am on the page for the torrent
     Then I should see "single" within the page title
      And I should see "<size>" within the content size within the transfer of the torrent
      And I should see "<progress>" within the progress within the transfer of the torrent
      And I should see "<up>" within the up rate within the transfer of the torrent
      And I should see "<down>" within the down rate within the transfer of the torrent

    Examples:
      | scenario                | size    | up          | down        | progress |
      | the torrent was started | 71.7 KB | 0 B/s       | 0 B/s       | 0%       |
      | nothing                 | 71.7 KB | not running | not running | 0%       |
      | rtorrent shuts down     | 71.7 KB | unavailable | unavailable | 0%       |
