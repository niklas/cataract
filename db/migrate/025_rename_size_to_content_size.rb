class RenameSizeToContentSize < ActiveRecord::Migration
  def self.up
    rename_column :torrents, :size, :content_size
  end

  def self.down
    rename_column :torrents, :content_size, :size
  end
end
