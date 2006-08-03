class Users < ActiveRecord::Migration
  def self.up
    create_table :users do |table|
      table.column :name, :string
      table.column :login, :string
      table.column :email, :string
      table.column :jabber, :string
      table.column :notify_via_jabber, :boolean
      table.column :notify_on_comments, :boolean
      table.column :notify_on_my_torrents, :boolean
      table.column :picture_url, :string
    end
  end

  def self.down
    drop_table :users
  end
end
