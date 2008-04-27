require File.join(File.dirname(__FILE__), "../config/environment")
require 'drb'
require 'drb/acl'

class QueueManager
  class Job
    @@all_tasks = []
    attr_accessor :status
    def initialize(*args)
      @status = {}
      @finished = false
      @@all_tasks << self
    end
    def finished?
      @finished
    end
    def finish!
      @finished = true
    end
  end
  attr_accessor :queue
  attr_accessor :jobs
  attr_accessor :worker
  
  def initialize
    self.queue = []
    self.jobs = {}
    load_job_definitions
    init_worker
    @mutext = Mutex.new
  end

  def status_for(key)
    job = jobs[key]
    job ? job.status : nil
  end

  def job_finished?(key)
    job = jobs[key]
    job ? job.finished? : nil
  end

  def delete_job(key)
    job = jobs.delete(key)
    queue.delete job if job
  end

  def create_job(klass_name,key,*args)
    klass = "#{klass_name}_job".classify.constantize
    job = klass.new(*args)
    add_job(key,job)
  end


  protected
  def add_job(key,job)
    if jobs[key] && job_finished?(key)
      delete_job(key)
    end
    unless jobs[key]
      jobs[key] = job
      self.queue << job
      puts "Added #{key}"
      self.worker.wakeup
    else
      raise "there is already a job called #{key}"
    end
  end
  
  def init_worker
    self.worker = Thread.new do
      loop do
        Thread.stop
        execute_queue
      end
    end
  end
    
  def execute_queue
    @mutext.synchronize do 
      until self.queue.empty?
        fu = self.queue.pop
        fu.do_work unless fu.nil?
      end
    end
  end

  def load_job_definitions
    path = File.join(File.dirname(__FILE__), 'jobs')
    Dir["#{path}/*"].each do |jobfile|
      require jobfile
    end
  end
  
end

DRb.start_service(Settings.queue_manager_url, qm = QueueManager.new)

puts "Ready."
qm.worker.join
DRb.thread.join
