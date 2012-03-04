class RemoveContentPathFromTorrents < ActiveRecord::Migration
  def up
    remove_column :torrents, :content_path
      end

  def down
    add_column :torrents, :content_path, :string, :limit => 2048
  end
end
