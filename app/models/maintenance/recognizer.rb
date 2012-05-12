# looks in the torrent_dir for new torrent files and creates them
class Maintenance::Recognizer < Maintenance::Base

  def work
    created = []
    Directory.watched.each do |directory|
      logger.info { "sync - in #{directory.path}" }
      directory.glob('*.torrent').each do |filepath|
        logger.info { "sync - found: #{filepath}" }
        torrent = Torrent.new(status: 'new', file: File.open(filepath))
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
