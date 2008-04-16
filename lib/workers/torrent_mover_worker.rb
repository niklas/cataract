require 'rsync/rsync'

class TorrentMoverWorker < BackgrounDRb::Worker::RailsBase
  def do_work(torrent_id,target)
    results[:begun_work_at] = Time.now.to_s
    results[:progress] = 0.0
    results[:file_progress] = 0.0
    results[:action] = '[.. starting up ..]'
    logger.info("Will move Torrent ##{torrent_id} to #{target}")
    torrent = Torrent.find(torrent_id)
    Rsync.copy(torrent.content_path,target) do |progress,current_file,file_progress|
      results[:progress] = progress
      results[:action] = "Copying '#{File.basename(current_file)}'"
      results[:file_progress] = file_progress
    end
  rescue Exception => e
    logger.error("Moving went wrong: #{e.message}")
  end
end
TorrentMoverWorker.register
