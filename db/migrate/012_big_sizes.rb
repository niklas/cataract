class BigSizes < ActiveRecord::Migration
  def self.up
    change_column :torrents, :size, :string
    # limit not supported for postgres yet
  end

  def self.down
    change_column :torrents, :size, :integer
  end
end
