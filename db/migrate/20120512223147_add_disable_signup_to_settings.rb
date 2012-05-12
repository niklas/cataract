class AddDisableSignupToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :disable_signup, :boolean

  end
end
