class OptOutAddingToWatchlist < ActiveRecord::Migration
  def self.up
    add_column :users, :dont_watch_new_torrents, :boolean, default: false
  end

  def self.down
    remove_column :users, :dont_watch_new_torrents
  end
end
