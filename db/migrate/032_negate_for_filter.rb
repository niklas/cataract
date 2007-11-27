class NegateForFilter < ActiveRecord::Migration
  def self.up
    add_column :filters, :negated, :boolean
  end

  def self.down
    remove_column :filters, :negated
  end
end
