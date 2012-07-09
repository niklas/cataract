class RenameDirectoryPathToRelativePath < ActiveRecord::Migration
  def up
    rename_column :directories, :path, :relative_path
  end

  def down
    rename_column :directories, :relative_path, :path
  end
end
