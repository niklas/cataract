class AlterUsersForDevise < ActiveRecord::Migration
  def up
    change_column :users, :email, :string, :default => "", :null => false, :limit => 128
    rename_column :users, :crypted_password, :encrypted_password
    change_column :users, :encrypted_password, :string, :limit => 128, :default => "", :null => false
    rename_column :users, :salt, :password_salt
    change_column :users, :password_salt, :string, :default => "", :null => false, :limit => 255
    add_column :users, :reset_password_token, :string
    change_column :users, :remember_token, :string, :limit => 255
    rename_column :users, :remember_token_expires_at, :remember_created_at

    add_column :users, :sign_in_count, :integer, :default => 0
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string

    add_column :users, :confirmation_token, :string, :limit => 255
    add_column :users, :confirmed_at, :datetime

    add_column :users, :confirmation_sent_at, :datetime
  end

  def down
    rename_column :users, :encrypted_password, :crypted_password
    change_column :users, :crypted_password, :string, :limit => 40
    rename_column :users, :password_salt, :salt
    change_column :users, :salt, :string, :limit => 40
    remove_column :users, :reset_password_token
    change_column :users, :remember_token, :string, :limit => 40
    rename_column :users, :remember_created_at, :remember_token_expires_at

    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip

    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at

    remove_column :users, :confirmation_sent_at
  end
end
