class StampsForTorrent < ActiveRecord::Migration
  def self.up
    change_table :torrents do |t|
      t.userstamps
    end
  end

  def self.down
    remove_column :torrents, :created_by
    remove_column :torrents, :updated_by
  end
end
