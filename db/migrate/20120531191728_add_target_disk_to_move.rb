class AddTargetDiskToMove < ActiveRecord::Migration
  def change
    add_column :moves, :target_disk_id, :integer

  end
end
