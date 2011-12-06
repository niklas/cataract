class Worker

  def self.start(*a)
    new.start(*a)
  end

  attr_reader :channel, :options

  def initialize(channel, options={})
    @channel = channel
    @options = options
  end

  def running?
    @running
  end

  def start
    @running = true
    handle_signals
  end

  private

  def handle_signals
    %W(INT TERM).each do |sig|
      trap(sig) do
        if running?
          @running = false
          log("worker running=#{@running}")
        else
          raise Interrupt
        end
      end
    end
  end

end
