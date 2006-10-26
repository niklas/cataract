class UrlForTorrents < ActiveRecord::Migration
  def self.up
    add_column :torrents, :url, :text
  end

  def self.down
    remove_column :torrents, :url
  end
end
