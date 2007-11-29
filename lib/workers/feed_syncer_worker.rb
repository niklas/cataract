class FeedSyncerWorker < BackgrounDRb::Worker::RailsBase
  
  def do_work(args)
    feeds = Feed.find :all
    feeds.each_with_index do |feed, idx|
      results[:progress] = 100.0 * idx/feeds.size
      feed.sync
    end
    results[:progress] = 100.0
  end

end
FeedSyncerWorker.register
