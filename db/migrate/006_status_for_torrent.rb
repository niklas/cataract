class StatusForTorrent < ActiveRecord::Migration
  def self.up
    add_column :torrents, :status, :string
  end

  def self.down
    remove_column :torrents, :status
  end
end
