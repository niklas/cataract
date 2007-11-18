class LogEntry
  attr_reader :message, :level
  def initialize(msg,level=:log)
    @message = msg
    @level = level
  end
end
