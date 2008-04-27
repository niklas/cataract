class FeedSyncerJob < QueueManager::Job
  
  def do_work
    feeds = Feed.find :all
    feeds.each_with_index do |feed, idx|
      status[:progress] = 100.0 * idx/feeds.size
      feed.sync
    end
    status[:progress] = 100.0
    finish!
  end

end
