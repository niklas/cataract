#!/usr/bin/env ruby

require 'fusefs'
require File.dirname(__FILE__) + '/../config/environment'

class TorrentTagFS < FuseFS::FuseDir
  def directory? path
      tag, torrent, payload = scan_path path
      puts "directory? #{tag} - #{torrent} - #{payload}"
      case
      when payload
        false
      when !torrent.blank? # /tag/torrent
        true
      when !tag.blank?     # /tag
        true
      else
        false
      end
  end
  def file? path
      tag, torrent, payload = scan_path path
      puts "file? #{tag}:#{torrent}:#{payload}"
      !payload.blank?
  end
  def can_delete?; false end
  def can_write? path; false end

  def contents path
      tag, torrent, payload = scan_path path
      puts "contents #{tag}:#{torrent}:#{payload}"
      if tag.blank? # root, list all tags
        puts "find all tags"
        Tag.find(:all).map { |t| t.name }
      elsif torrent.blank? # first level
        puts "find all torrents tagged with #{tag}"
        torrents = Torrent.find_tagged_with tag
        torrents.map { |t| [t.id,t.short_title].join('-') }
      elsif payload.blank?
        [Torrent.find(torrent).content_root]
      else
        ["contents of #{payload}"]
      end
  end
  def read_file path
      tag, torrent, payload = scan_path path
      %Q[payload of [#{payload}]]
  end
end

if (File.basename($0) == File.basename(__FILE__))
    root = TorrentTagFS.new
    FuseFS.set_root(root)
    FuseFS.mount_under(ARGV[0])
    FuseFS.run # This doesn't return until we're unmounted.
end

