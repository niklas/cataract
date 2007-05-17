class SyncronizedFieldForTorrent < ActiveRecord::Migration
  def self.up
    add_column :torrents, :synched_at, :datetime
  end

  def self.down
    remove_column :torrents, :synched_at
  end
end
