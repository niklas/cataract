class AddSubscribedFlagToDirectories < ActiveRecord::Migration
  def change
    add_column :directories, :subscribed, :boolean

  end
end
