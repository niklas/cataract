class CreateMaintenances < ActiveRecord::Migration
  def change
    create_table :maintenances do |t|
      t.timestamp :locked_at
      t.string :type

      t.timestamps
    end
  end
end
