class MountPointsForUser < ActiveRecord::Migration
  def self.up
    add_column :users, :content_dir_mountpoint, :text
    add_column :users, :target_dir_mountpoint, :text
  end

  def self.down
    remove_column :users, :content_dir_mountpoint
    remove_column :users, :target_dir_mountpoint
  end
end
