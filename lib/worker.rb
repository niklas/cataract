class Worker

  class ReachedMaxAttempts < RuntimeError; end

  def self.start(*a)
    new.start(*a)
  end

  attr_reader :channel, :options

  def initialize(channel, options={})
    @channel = channel
    @options = options.with_indifferent_access
    @attempts = @options.delete(:attempts) || 5
  end

  def running?
    @running
  end

  def start
    @running = true
    handle_signals
    while running?
      work
    end
  end

  def work
    if job = lock_job
      log("locked #{job}")
      begin
        job.work
        log("finished #{job}")
      rescue Exception => e
        log("failed #{job}:\n   #{e.inspect}")
        handle_failure(job, e)
      ensure
        job.destroy
        log("destroyed #{job}")
      end
    end
  end

  def lock_job
    attempting do
      next_job
    end
  end

  def next_job
    job_class.locked.first
  end


  private

  def attempting
    raise ArgumentError, "must give a block" unless block_given?
    @attempts.times do |attempt|
      if success = yield
        return success
      end
      if attempt < @attempts
        wait 2**attempt
      end
    end
    raise ReachedMaxAttempts, "tried #{@attempts} times"
  end

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

  # TODO this should be decoupled. Must give class_name instead of channel to worker
  def job_class
    channel.classify.constantize
  end

  #override this method to do whatever you want
  def handle_failure(job,e)
    STDERR.puts "!"
    STDERR.puts "! \t FAIL"
    STDERR.puts "! \t \t #{job.inspect}"
    STDERR.puts "! \t \t #{e.inspect}"
    STDERR.puts "!"
  end

  def log(message)
    Rails.logger.info("#{self.class} #{message}")
  end

end
