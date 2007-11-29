class NegateForFilter < ActiveRecord::Migration
  def self.up
    # whoops, dropped filters, so re-create it. (damned)
    create_table 'filters' do |t|
      t.column :expression, :string
      t.column :feed_id, :integer
      t.column :negated, :boolean
    end
  end

  def self.down
    drop_table :filters
  end
end
