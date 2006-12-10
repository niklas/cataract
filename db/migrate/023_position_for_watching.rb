class PositionForWatching < ActiveRecord::Migration
  def self.up
    add_column :watchings, :position, :integer
  end

  def self.down
    drop_column :watchings, :position
  end
end
