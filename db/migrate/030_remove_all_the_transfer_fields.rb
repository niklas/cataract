class RemoveAllTheTransferFields < ActiveRecord::Migration
  def self.up
    remove_column :torrents, "percent_done"
    remove_column :torrents, "rate_up"
    remove_column :torrents, "rate_down"
    remove_column :torrents, "transferred_up"
    remove_column :torrents, "transferred_down"
    remove_column :torrents, "peers"
    remove_column :torrents, "seeds"
    remove_column :torrents, "distributed_copies"
    remove_column :torrents, "statusmsg"
    remove_column :torrents, "errormsg"
  end

  def self.down
    add_column :torrents, "percent_done",       :float
    add_column :torrents, "rate_up",            :float
    add_column :torrents, "rate_down",          :float
    add_column :torrents, "transferred_up",     :integer
    add_column :torrents, "transferred_down",   :integer
    add_column :torrents, "peers",              :integer
    add_column :torrents, "seeds",              :integer
    add_column :torrents, "distributed_copies", :float
    add_column :torrents, "statusmsg",          :string
    add_column :torrents, "errormsg",           :string,   :limit => 512
  end
end
