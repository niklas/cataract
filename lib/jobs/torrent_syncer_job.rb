class TorrentSyncerJob < QueueManager::Job
  
  def do_work
    Torrent.sync
  end

end
