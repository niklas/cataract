class RemoveFilters < ActiveRecord::Migration
  def up
    drop_table :filters
  end

  def down
    create_table "filters", :force => true do |t|
      t.string  "expression"
      t.integer "feed_id"
      t.boolean "negated"
      t.integer "position"
    end
  end
end
