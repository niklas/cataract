class NotificateIsNotAWord < ActiveRecord::Migration
  def self.up
    rename_column :watchings, :notificate, :notify
  end

  def self.down
    rename_column :watchings, :notify, :notificate
  end
end
