class CreateDirectories < ActiveRecord::Migration
  def self.up
    create_table :directories do |t|
      t.string :name
      t.string :path, :limit => 2048

      t.timestamps
    end
  end

  def self.down
    drop_table :directories
  end
end
