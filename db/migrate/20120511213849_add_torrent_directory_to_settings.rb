class AddTorrentDirectoryToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :torrent_directory_id, :integer

  end
end
