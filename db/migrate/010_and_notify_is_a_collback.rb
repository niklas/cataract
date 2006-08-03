class AndNotifyIsACollback < ActiveRecord::Migration
  def self.up
    rename_column :watchings, :notify, :apprise
  end

  def self.down
    rename_column :watchings, :apprise, :notify
  end
end
