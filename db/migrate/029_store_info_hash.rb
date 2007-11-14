class StoreInfoHash < ActiveRecord::Migration
  def self.up
    add_column :torrents, :info_hash, :string, :limit => 40
  end

  def self.down
    remove_column :torrents, :info_hash
  end
end
