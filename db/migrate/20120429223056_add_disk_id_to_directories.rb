class AddDiskIdToDirectories < ActiveRecord::Migration
  def change
    add_column :directories, :disk_id, :integer
    add_index :directories, :disk_id
  end
end
