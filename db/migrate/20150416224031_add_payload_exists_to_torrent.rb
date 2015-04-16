class AddPayloadExistsToTorrent < ActiveRecord::Migration
  def change
    add_column :torrents, :payload_exists, :boolean
  end
end
