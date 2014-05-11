class RenameTorrentsDirectoryIdToContentDirectoryId < ActiveRecord::Migration
  def up
    rename_column :torrents, :directory_id, :content_directory_id
  end

  def down
    rename_column :torrents, :content_directory_id, :directory_id
  end
end
