class TorrentRecognizerWorker < BackgrounDRb::Worker::RailsBase
  
  def do_work(args)
    Torrent.recognize_new
  end

end
TorrentRecognizerWorker.register
