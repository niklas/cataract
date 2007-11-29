class TorrentSyncerWorker < BackgrounDRb::Worker::RailsBase
  
  def do_work(args)
    Torrent.sync
  end

end
TorrentSyncerWorker.register
