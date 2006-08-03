class CreateWatchings < ActiveRecord::Migration
  def self.up
    create_table :watchings do |t|
      t.column :user_id,    :integer, :null => false
      t.column :torrent_id, :integer, :null => false
      t.column :created_at, :datetime
      t.column :notificate, :boolean
    end
    remove_column :torrents, :user_id
  end

  def self.down
    drop_table :watchings
    add_column :torrents, :user_id, :integer
  end
end
