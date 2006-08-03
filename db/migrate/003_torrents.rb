class Torrents < ActiveRecord::Migration
  def self.up
    create_table :torrents do |table|
      table.column :user_id, :integer
      table.column :title, :string
      table.column :description, :string
      table.column :size, :integer
      table.column :filename, :string
      table.column :percent_done, :float
      table.column :rate_up, :float
      table.column :rate_down, :float
      table.column :transferred_up, :integer
      table.column :transferred_down, :integer
      table.column :peers, :integer
      table.column :seeds, :integer
      table.column :distributed_copies, :float
      table.column :hidden, :boolean
      table.column :command, :string
      table.column :statusmsg, :string
      table.column :errormsg, :string
      table.column :created_at, :timestamp
      table.column :updated_at, :timestamp
    end
  end

  def self.down
    drop_table :torrents
  end
end
