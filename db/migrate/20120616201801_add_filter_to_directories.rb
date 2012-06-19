class AddFilterToDirectories < ActiveRecord::Migration
  def change
    add_column :directories, :filter, :string

  end
end
