class SetupQueueLockFunction < ActiveRecord::Migration
  Queueable # FIXME just mentioning this here to load it, have to put te psql code into an initializer
  def up
    create_queueable_lock_function
  end

  def down
    drop_queueable_lock_function
  end
end
