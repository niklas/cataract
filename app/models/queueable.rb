module Queueable

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      after_save :notify, :on => :create
    end
  end

  module ClassMethods

    def queue_name
      table_name
    end

    def wait_for_new_record(timeout=100)
      listen!
      connection.wait_for_notify(timeout)
    ensure
      unlisten!
    end

    def listen!
      connection.listen queue_name
    end
    def unlisten!
      connection.unlisten queue_name
    end

    private
    def notify
      connection.notify queue_name
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

  def wait_for_notify(*a, &block)
    @connection.wait_for_notify(*a, &block)
  end

  def notifies
    @connection.notifies
  end

end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  include PostgreSQLNotifications
end
