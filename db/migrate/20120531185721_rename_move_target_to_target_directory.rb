class RenameMoveTargetToTargetDirectory < ActiveRecord::Migration
  def up
    rename_column :moves, :target_id, :target_directory_id
  end

  def down
    rename_column :moves, :target_directory_id, :target_id
  end
end
