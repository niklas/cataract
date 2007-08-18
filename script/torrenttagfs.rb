#!/usr/bin/env ruby

require 'fusefs'
require File.dirname(__FILE__) + '/../config/environment'

class TorrentTagFS < FuseFS::FuseDir
  def initialize
    @files = Hash.new(nil)
  end
  def directory? path
      tag, torrent, payload = scan_path path
      case
      when payload
        if t = Torrent.find(torrent) && t.content_single?
          false
        else
          true
        end
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
      if payload
        t = Torrent.find(torrent)
        if t.content_single?
          payload == t.content_root.first
        else
          t.content_root.include?(payload)
        end
      else
        false
      end
  end
  def size path
    tag, torrent, payload = scan_path path
    case
    when payload
      rp = real_path(path)
      File.size( real_path(path) )
    when !torrent.blank?
      Torrent.find(torrent).content_size
    when !tag.blank?
      Torrent.find_tagged_with(tag).size
    else
      23
    end
  end
  def can_delete?; false end
  def can_write? path; false end

  def contents path
      tag, torrent, payload = scan_path path
      if tag.blank? # root, list all tags
        Tag.find(:all).map { |t| t.name }
      elsif torrent.blank? # first level
        torrents = Torrent.find_tagged_with tag
        torrents.map { |t| [t.id,t.short_title].join('-') }
      elsif payload.blank?
        if t = Torrent.find(torrent)
          t.content_root
        else
          ["torrent not found"]
        end
      else
        t = Torrent.find(torrent)
        if t.content_single?
          false
        else
          t.content_filenames
        end
      end
  end
  def raw_open path, mode
    return true if @files.has_key? path
    location = real_path path
    @files[path] = File.open(location, mode)
    return true
  rescue
    puts $!
    false
  end

  def raw_read path, off, size
    file = @files[path]
    return unless file
    file.seek(off, File::SEEK_SET)
    file.read(size)
  rescue
    puts $!
    nil
  end
  def raw_close(path)
    file = @files[path]
    return unless file
    file.close
    @files.delete path
  rescue
    puts $!
  end
  def __read_file path
      tag, torrent, payload = scan_path path
      %Q[payload of [#{payload}]]
  end
  private
  def real_path path
    tag, torrent, payload = scan_path path
    return unless t = Torrent.find(torrent)
    dir = t.content_path
    t.content_single? ? dir : File.join(dir,payload)
  end
end

if (File.basename($0) == File.basename(__FILE__))
    root = TorrentTagFS.new
    FuseFS.set_root(root)
    target = ARGV[0]
    puts "mounting #{target}"
    FuseFS.mount_under(target,'allow_other')
    FuseFS.run # This doesn't return until we're unmounted.
end

