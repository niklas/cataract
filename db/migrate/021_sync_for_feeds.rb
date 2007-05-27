class SyncForFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :synced_at, :datetime
    add_column :feeds, :item_limit, :integer, :default => 100
  end

  def self.down
    remove_column :feeds, :synced_at
    remove_column :feeds, :item_limit
  end
end
