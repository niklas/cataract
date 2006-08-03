class NotifyOnNewTorrents < ActiveRecord::Migration
  def self.up
    add_column :users, 'notify_on_new_torrents', :boolean
  end

  def self.down
    remove_column :users, 'notify_on_new_torrents'
  end
end
