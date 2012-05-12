class AddFileToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :file, :string

  end
end
