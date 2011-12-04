class AddWatchedToDirectories < ActiveRecord::Migration
  def change
    add_column :directories, :watched, :boolean
  end
end
