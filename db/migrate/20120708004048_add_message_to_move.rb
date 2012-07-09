class AddMessageToMove < ActiveRecord::Migration
  def change
    add_column :moves, :message, :text

  end
end
