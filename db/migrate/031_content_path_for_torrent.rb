class ContentPathForTorrent < ActiveRecord::Migration
  def self.up
    add_column :torrents, :content_path, :string, :limit => 2048
  end

  def self.down
    remove_column :torrents, :content_path
  end
end
