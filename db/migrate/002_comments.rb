class Comments < ActiveRecord::Migration
  def self.up
    create_table :comments do |table|
      table.column :torrent_id, :integer
      table.column :user_id, :integer
      table.column :content, :string
      table.column :created_at, :timestamp
    end
  end

  def self.down
    drop_table :comments
  end
end
