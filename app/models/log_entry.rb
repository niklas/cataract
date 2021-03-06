class LogEntry < ActiveRecord::Base
  belongs_to :loggable, :polymorphic => true
  belongs_to :user

  def self.page_size
    23
  end
  def self.error(msg='Random Error Message')
    log(msg,:error)
  end
  def self.warning(msg='Random Warning Message')
    log(msg,:warn)
  end
  def self.warn(msg='Random Warning Message')
    log(msg,:warn)
  end
  def self.info(msg='Random Info Message')
    log(msg,:info)
  end
  def self.notice(msg='Random Notice Message')
    log(msg,:info)
  end
  def self.notification(msg='Random Notice Message')
    log(msg,:info)
  end
  def self.log(message,level=:info)
    create(:message => message, :level => level.to_s)
  end

  def final_message
    returning '' do |msg|
      msg << if !message.blank?
               message
             elsif loggable.nil?
               "something #{action}"
             else
               "'#{loggable.nice_title}' #{action}"
             end
      unless user.nil?
        msg << " by #{user.name_or_login}"
      end
    end
  end

  def self.after(last_entry=nil)
    if last_entry
      @log_entries = LogEntry.last.older_than(last_entry)
    else
      @log_entries = LogEntry.last
    end
  end

  def self.last
    order('created_at DESC').limit(page_size)
  end

  def self.older_than(newest)
    nid = newest.split('_').last.to_i
    where("id < ?", nid)
  end
end
