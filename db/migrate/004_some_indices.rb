class SomeIndices < ActiveRecord::Migration
  def self.up
    add_index :comments, :content
    add_index :torrents, :filename
    add_index :torrents, :title
    add_index :torrents, :description
  end

  def self.down
    remove_index :comments, :content
    remove_index :torrents, :filename
    remove_index :torrents, :title
    remove_index :torrents, :description
  end
end
