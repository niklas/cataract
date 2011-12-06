class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :torrent_id
      t.timestamp :locked_at
      t.integer :target_id

      t.timestamps
    end
  end
end
