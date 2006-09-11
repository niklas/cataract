class CreateFilters < ActiveRecord::Migration
  def self.up
    create_table :filters do |t|
      t.column :expression, :string
      t.column :feed_id, :integer
    end
  end

  def self.down
    drop_table :filters
  end
end
