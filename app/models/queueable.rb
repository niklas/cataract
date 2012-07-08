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

    # calling this at the end of a scope chain will lock the record and fetch it from the db
    # FIXME: must reload the record because #locked_at is set to late in the psql query process,by the function in WHERE.
    def locked
      where(["id = #{PostgreSQLNotifications::LockFunctionName}(?)", table_name]).first.tap do |locked|
        locked.reload if locked.present?
      end
    end

    private
    def notify
      connection.notify queue_name
    end

  end

  def acts_like_queueable?
    true
  end

  # TODO move away
  def work!
    logger.debug { "#{self.class} working..." }
    work
    logger.debug { "#{self.class} finished" }
  rescue Exception => e
    handle_failure(e)
    raise e
  end

  def handle_failure(exception)
    update_attributes! locked_at: nil, message: exception.inspect
  end


  private

  def notify
    self.class.send(:notify)
  end

end

# TODO extract and test
module PostgreSQLNotifications
  LockFunctionName = 'queue_lock'

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

  def queueable_top_boundry
    10
  end

  # Sets up the function used in the .locked scope
  # assumes two existing columns: id, locked_at timestamp
  def create_queueable_lock_function
    execute(<<-EOD)
      CREATE OR REPLACE FUNCTION #{quote_table_name LockFunctionName}(tname varchar) RETURNS integer AS $$
      DECLARE
        unlocked integer;
        relative_top integer;
        job_count integer;
      BEGIN
        -- The purpose is to release contention for the first spot in the table.
        -- The select count(*) is going to slow down dequeue performance but allow
        -- for more workers. Would love to see some optimization here...

        EXECUTE 'SELECT count(*) FROM' || tname || '' INTO job_count;
        IF job_count < #{queueable_top_boundry} THEN
          relative_top = 0;
        ELSE
          SELECT TRUNC(random() * #{queueable_top_boundry} + 1) INTO relative_top;
        END IF;

        LOOP
          BEGIN
            EXECUTE 'SELECT id FROM '
              || tname::regclass
              || ' WHERE locked_at IS NULL'
              || ' ORDER BY id ASC'
              || ' LIMIT 1'
              || ' OFFSET ' || relative_top
              || ' FOR UPDATE NOWAIT'
            INTO unlocked;
            EXIT;
          EXCEPTION
            WHEN lock_not_available THEN
              -- do nothing. loop again and hope we get a lock
              -- FIXME won't this loop forever?
          END;
        END LOOP;

        IF unlocked IS NOT NULL THEN
          EXECUTE 'UPDATE '
            || tname::regclass
            || ' SET locked_at = (CURRENT_TIMESTAMP)'
            || ' WHERE id = $1'
            || ' AND locked_at is NULL'
          USING unlocked;
        END IF;

        RETURN unlocked;
      END;
      $$ LANGUAGE plpgsql;
    EOD

  end

  def drop_queueable_lock_function
    execute(<<-EOD)
      DROP FUNCTION IF EXISTS #{quote_table_name LockFunctionName}(tname varchar)
    EOD
  end

end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  include PostgreSQLNotifications
end
