@rootfs
@rtorrent
Feature: Load a torrent into RTorrent
  In order to start a download
  I want to load a torrent by path into RTorrent

  Scenario: loading as first
    Given a existing directory exists with path: "incoming"
      And a torrent_with_picture_of_tails exists with title: "Tails", directory: the directory, content_directory: the directory
      And the file for the torrent exists
     When I load the torrent
     Then the rtorrent main view should contain the torrent
