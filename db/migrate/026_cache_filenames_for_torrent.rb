class CacheFilenamesForTorrent < ActiveRecord::Migration
  def self.up
    add_column :torrents, :content_filenames, :text
  end

  def self.down
    remove_column :torrents, :content_filenames
  end
end
