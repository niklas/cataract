class AddDirectoryToTorrentAgain < ActiveRecord::Migration
  def change
    add_column :torrents, :directory_id, :integer
    add_index :torrents, :directory_id
  end
end
