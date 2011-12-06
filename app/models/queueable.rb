module Queueable

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      after_save :notify, :on => :create
    end
  end

  module ClassMethods

    def listen!
      connection.listen table_name
    end
    def unlisten!
      connection.unlisten table_name
    end

    private
    def notify
      connection.notify table_name
    end

  end

  private

  def notify
    self.class.send(:notify)
  end

end

# TODO extract and test
module PostgreSQLNotifications
  def notify(channel)
    execute %Q~NOTIFY #{quote_table_name(channel)}~
  end

  def listen(channel)
    execute %Q~LISTEN #{quote_table_name(channel)}~
  end

  def unlisten(channel)
    execute %Q~UNLISTEN #{quote_table_name(channel)}~
  end

  # #wait_for_notify is already implemented
  # so is #notifies
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  include PostgreSQLNotifications
end
