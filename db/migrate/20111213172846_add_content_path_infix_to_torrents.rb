class AddContentPathInfixToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :content_path_infix, :string
  end
end
