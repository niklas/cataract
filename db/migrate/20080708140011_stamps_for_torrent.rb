class StampsForTorrent < ActiveRecord::Migration
  def up
    add_column :torrents, :created_by, :integer
    add_column :torrents, :updated_by, :integer
  end
end
