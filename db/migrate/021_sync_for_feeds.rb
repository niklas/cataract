class SyncForFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :synced_at, :datetime
    add_column :feeds, :item_limit, :integer, :default => 100
  end

  def self.down
    drop_column :feeds, :synced_at
    drop_column :feeds, :item_limit
  end
end
