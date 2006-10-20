class OptOutAddingToWatchlist < ActiveRecord::Migration
  def self.up
    add_column :users, :dont_watch_new_torrents, :boolean
    User.find_all.each { |u| u.update_attribute :dont_watch_new_torrents, false}
  end

  def self.down
    remove_column :users, :dont_watch_new_torrents
  end
end
