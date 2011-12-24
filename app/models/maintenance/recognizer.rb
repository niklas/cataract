# looks in the torrent_dir for new torrent files and creates them
class Maintenance::Recognizer < Maintenance::Base

  def work
    created = []
    Directory.watched.each do |directory|
      logger.info { "sync - in #{directory.path}" }
      directory.glob('*.torrent').each do |filepath|
        logger.info { "sync - found: #{filepath}" }
        filename = File.basename filepath
        torrent = directory.torrents.build(:filename => filename, :status => 'new')
        if torrent.save
          #torrent.moveto(:archived)
          #torrent.finally_stop!
          created << torrent 
          #torrent.start!
        else
          logger.info "sync - could not create Torrent from #{filepath}: #{torrent.errors.full_messages.join(',')}"
        end
      end
    end
    return created

  end

end
