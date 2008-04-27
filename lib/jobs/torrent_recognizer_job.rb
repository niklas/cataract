class TorrentRecognizerJob < QueueManager::Job
  
  def do_work
    Torrent.recognize_new
  end

end
