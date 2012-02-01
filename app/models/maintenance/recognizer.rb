# looks in the torrent_dir for new torrent files and creates them
class Maintenance::Recognizer < Maintenance::Base

  def work
    created = []
    Directory.watched.each do |directory|
      logger.info { "sync - in #{directory.path}" }
      directory.glob('*.torrent').each do |filepath|
        logger.info { "sync - found: #{filepath}" }
        filename = File.basename filepath
        torrent = directory.torrents.build(:filename => filename, :status => 'new', :content_directory => directory)
        if torrent.save
          created << torrent 
        else
          logger.info "sync - could not create Torrent from #{filepath}: #{torrent.errors.full_messages.join(',')}"
        end
      end
    end
    created.each(&:start!)
  end

end
