class AddAncestryToDirectories < ActiveRecord::Migration
  def change
    add_column :directories, :ancestry, :string
    add_index :directories, :ancestry
  end
end
