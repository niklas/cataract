class ShowSubDirsForDirectory < ActiveRecord::Migration
  def self.up
    add_column :directories, :show_sub_dirs, :boolean, :default => false
  end

  def self.down
    remove_column :directories, :show_sub_dirs
  end
end
