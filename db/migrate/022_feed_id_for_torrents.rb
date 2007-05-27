class FeedIdForTorrents < ActiveRecord::Migration
  def self.up
    add_column :torrents, :feed_id, :integer
  end

  def self.down
    remove_column :torrents, :feed_id
  end
end
