class CreateSettings < ActiveRecord::Migration
  def up
    execute %Q~DROP TABLE IF EXISTS settings~
    create_table :settings do |t|
      t.integer :incoming_directory_id

      t.timestamps
    end
  end

  def down
    drop_table :settings
  end
end
