class SchedulerJob < QueueManager::Job
  def initialize
    @drb = DRbObject.new(nil, Settings.queue_manager_url)
    super
  end
  def do_work
    # TODO simulate cronjob here
    finish! # neva!
  end
end
