class FooJob < QueueManager::Job
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

