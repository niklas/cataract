class CreateLogEntries < ActiveRecord::Migration
  def self.up
    create_table :log_entries do |t|
      t.string :action
      t.string :level
      t.integer :user_id
      t.text :message
      t.integer :loggable_id
      t.string :loggable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :log_entries
  end
end
