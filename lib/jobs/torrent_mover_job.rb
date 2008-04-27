require 'rsync/rsync'

class TorrentMoverJob < QueueManager::Job
  def initialize(torrent_id,target)
    @torrent = Torrent.find(torrent_id)
    @target = target
    super
  end

  def do_work
    status[:begun_work_at] = Time.now.to_s
    status[:progress] = 0.0
    status[:file_progress] = 0.0
    status[:action] = '[.. starting up ..]'
    old_state = @torrent.current_state
    @torrent.update_attribute(:status,'moving')
    Rsync.copy(@torrent.content_path, @target) do |progress,current_file,file_progress|
      status[:progress] = progress if progress
      status[:action] = "Copying '#{File.basename(current_file)}'" unless current_file.blank?
      status[:file_progress] = file_progress if file_progress
    end
    status[:action] = "Deleting old stuff."
    FileUtils.rm_rf @torrent.content_path
    @torrent.update_attribute(:content_path, @target)
    status[:progress] = 100
  rescue Exception => e
    puts("Moving went wrong: #{e.message}. #{e.backtrace}")
  ensure
    @torrent.update_attribute(:status,old_state.to_s)
    finish!
  end
end
