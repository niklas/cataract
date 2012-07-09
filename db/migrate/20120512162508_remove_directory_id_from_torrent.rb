class RemoveDirectoryIdFromTorrent < ActiveRecord::Migration
  def up
    remove_column :torrents, :directory_id
      end

  def down
    add_column :torrents, :directory_id, :integer
  end
end
