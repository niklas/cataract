class Worker

  def self.start(*a)
    new.start(*a)
  end

  attr_reader :channel, :options

  def initialize(channel, options={})
    @channel = channel
    @options = options
  end

end
