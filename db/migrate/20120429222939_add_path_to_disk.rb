class AddPathToDisk < ActiveRecord::Migration
  def change
    add_column :disks, :path, :string
  end
end
