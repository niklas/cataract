@rtorrent
@rootfs
Feature: recognize torrents
  In order to not having to log in every day
  As a lazy user
  I want downloads recognized automatically

  Scenario: recognize torrents only in watched directories
    Given a disk exists with path: "media"
      And the following directories exist:
        | directory | relative_path | watched | disk     |
        | torrents  | torrents      | true    | the disk |
        | else      | else          | false   | the disk |
      And the following filesystem structure exists on disk:
        | type | path                           |
        | file | media/torrents/oneiric.torrent |
        | file | media/else/natty.torrent       |
     When the Recognizer runs
     Then a torrent should exist with filename: "oneiric.torrent"
      And directory "torrents" should be the torrent's content_directory
      And the torrent's info_hash should not be blank
      But 0 torrents should exist with filename: "natty.torrent"

  Scenario: recognize torrents are downloaded automatically
    Given a disk exists with path: "media"
      And the following directories exist:
        | directory | relative_path | watched | disk     |
        | torrents  | torrents      | true    | the disk |
      And the following filesystem structure exists on disk:
        | type | path                           |
        | file | media/torrents/oneiric.torrent |
     When the Recognizer runs
     Then a torrent should exist with filename: "oneiric.torrent"
      And the torrent's current_state should be "running"
      And rtorrent should download the torrent

  @todo
  Scenario: notify users by jabber

  @todo
  Scenario: recognize torrent's contents somewhere (with mlocate)

  Scenario: auto-fetch torrents for tv-shows in subscribed directories
    Given a disk exists with path: "media"
      And a torrent exists with filename: "fefebestfrowns.torrent"
      And the following directories exist:
        | directory | relative_path | subscribed | filter | disk     |
        | torrents  | torrents      | true       | frowns | the disk |
      And a feed exists with url: "http://ezrss.it/shows.rss"
      And the URL "http://ezrss.it/shows.rss" points to the following content:
      """
        <?xml version="1.0" encoding="UTF-8" ?>
        <!DOCTYPE torrent PUBLIC "-//bitTorrent//DTD torrent 0.1//EN" "http://xmlns.ezrss.it/0.1/dtd/">
        <rss version="2.0">
          <channel>
            <item>
              <title><![CDATA[Shame of Frowns - Final 7x24 [ROFLTV - KAGROUP]]]></title>
              <link>http://torrent.zoink.it/Shame of Frowns s07e24.torrent</link>
              <description><![CDATA[Show Name: Shame of Frowns - A Song of Clowns and Desire]]></description>
              <enclosure url="http://torrent.zoink.it/Shame of Frowns s07e24.torrent" length="12345" type="application/x-bittorrent" />
              <torrent xmlns="http://xmlns.ezrss.it/0.1/">
                <fileName><![CDATA[http://torrent.zoink.it/Shame of Frowns s07e24.torrent]]></fileName>
                <contentLength>12345</contentLength>
                <infoHash>AFFEAFFEAFFEAFFEAFFEAFFEAFFEAFFEAFFEAFFE</infoHash>
              </torrent>
            </item>
            <item>
              <title><![CDATA[Love and the Village]]></title>
              <link>http://torrent.zoink.it/love and the village.torrent</link>
              <description><![CDATA[Love and the Village]]></description>
              <enclosure url="http://torrent.zoink.it/love and the village.torrent" length="23456" type="application/x-bittorrent" />
              <torrent xmlns="http://xmlns.ezrss.it/0.1/">
                <fileName><![CDATA[http://torrent.zoink.it/love and the village.torrent]]></fileName>
                <contentLength>12345</contentLength>
                <infoHash>7070707070707070707070707070707070707070</infoHash>
              </torrent>
            </item>
            <item>
              <title><![CDATA[Fefe Best Of Frowns]]></title>
              <link>http://torrent.zoink.it/fefebestfrowns.torrent</link>
              <description><![CDATA[Fefe Best of Frowns]]></description>
              <enclosure url="http://torrent.zoink.it/fefebestfrowns.torrent" length="23456" type="application/x-bittorrent" />
              <torrent xmlns="http://xmlns.ezrss.it/0.1/">
                <fileName><![CDATA[http://torrent.zoink.it/fefebestfrowns.torrent]]></fileName>
                <contentLength>12345</contentLength>
                <infoHash>FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE</infoHash>
              </torrent>
            </item>
          </channel>
        </rss>
      """
      And the URL "http://torrent.zoink.it/Shame of Frowns s07e24.torrent" points to file "single.torrent"
     When the Recognizer runs
     Then a torrent "frowns" should exist with filename: "Shame_of_Frowns_s07e24.torrent", url: "http://torrent.zoink.it/Shame of Frowns s07e24.torrent"
      And directory "torrents" should be the torrent's content_directory
      And the torrent's file should exist on disk
      And the torrent's info_hash should not be blank
      And the torrent should be running

      # did not match filter
      But a torrent should not exist with url: "http://torrent.zoink.it/love and the village.torrent"
      # already exists ( by filename )
      And a torrent should not exist with url: "http://torrent.zoink.it/fefebestfrowns.torrent"


  @todo
  Scenario: recognize torrents that were added manually to rtorrent
