require File.join(File.dirname(__FILE__), "../config/boot")
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
  class FooJob < Job
    def initialize(max=23)
      @max = 23
      super
    end
    def do_work
      1.upto(@max) do |i|
        sleep 0.5
        status[:progress] = 100.0 * (i.to_f/@max)
      end
      finish!
    end
  end
  attr_accessor :queue
  attr_accessor :jobs
  attr_accessor :worker
  
  def initialize
    self.queue = []
    self.jobs = {}
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
    queue.delete job
  end

  def add_foo_job(key,max=nil)
    add_job(key,FooJob.new(max))
  end

  def add_job(key,job)
    unless jobs[key]
      puts "Adding #{key}"
      jobs[key] = job
      self.queue << job
      self.worker.wakeup
    else
      raise "there is already a job called #{key}"
    end
  end

  protected
  
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
        fu.do_work
      end
    end
  end
  
end

DRb.start_service("druby://127.0.0.1:5523", qm = QueueManager.new)

puts "Ready."
qm.worker.join
DRb.thread.join
