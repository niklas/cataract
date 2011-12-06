class Move < ActiveRecord::Base

  attr_accessible :target_id

  belongs_to :torrent
  belongs_to :target, :class_name => 'Directory'

  validates_numericality_of :torrent_id
  validates_numericality_of :target_id

  after_save :notify, :on => :create

  private
  def notify
    self.class.notify
  end

  def self.notify
    connection.notify table_name
  end

end

# TODO extract and test
module PostgreSQLNotifications
  def notify(channel)
    execute %Q~NOTIFY #{quote_table_name(channel)}~
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  include PostgreSQLNotifications
end
