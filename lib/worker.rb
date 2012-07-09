class Worker

  class ReachedMaxAttempts < RuntimeError; end

  def self.start(*a)
    new(*a).start
  end

  attr_reader :job_class_name, :options
  attr_accessor :attempts
  attr_writer :listen

  def initialize(job_class_name, options={})
    @job_class_name = job_class_name
    @options = options.with_indifferent_access
    @attempts = @options.delete(:attempts) || 5
    @listen  = @options[:listen] == false ? @options.delete(:listen) 
                                          : true
  end

  def running?
    @running
  end

  def start
    @running = true
    job_class.cleanup
    handle_signals
    while running?
      begin
        work
      rescue ReachedMaxAttempts => e
        log("#{e}, retrying")
      end
    end
  end

  def work
    job_class.transaction do
      if job = lock_job
        log("locked #{job}")
        begin
          job.work!
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
  end

  def lock_job
    attempting do
      next_job
    end
  end

  def next_job
    job_class.locked
  end

  def listen?
    @listen && job_class.connection.respond_to?(:wait_for_notify)
  end


  private

  def attempting(max=attempts)
    raise ArgumentError, "must give a block" unless block_given?
    max.times do |attempt|
      if success = yield
        return success
      end
      if attempt < max
        wait 2**attempt
      end
    end
    raise ReachedMaxAttempts, "tried #{max} times"
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
    job_class_name.constantize
  end

  #override this method to do whatever you want
  def handle_failure(job,e)
    STDERR.puts "!"
    STDERR.puts "! \t FAIL"
    STDERR.puts "! \t \t #{job.inspect}"
    STDERR.puts "! \t \t #{e.inspect}"
    STDERR.puts "!"
  end

  def wait(t)
    if listen?
      job_class.wait_for_new_record(t)
    else
      Kernel.sleep(t)
    end
  end

  def log(message)
    Rails.logger.info("#{self.class} #{message}")
  end

end
