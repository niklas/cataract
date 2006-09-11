class LongErrorMessages < ActiveRecord::Migration
  def self.up
    change_column :torrents, :errormsg, :string, :limit => 512
  end

  def self.down
    change_column :torrents, :errormsg, :string
  end
end
