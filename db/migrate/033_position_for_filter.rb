class PositionForFilter < ActiveRecord::Migration
  def self.up
    add_column :filters, :position, :integer
  end

  def self.down
    remove_column :filters, :postition
  end
end
