# looks in the torrent_dir for new torrent files and creates them
class Maintenance::Recognizer < Maintenance::Base

  def work
    on_disk
    in_net
  end

  def on_disk
    [].tap do |created|
      Directory.watched.each do |directory|
        logger.info { "sync - in #{directory.full_path}" }
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

  def in_net
    [].tap do |created|
      Directory.subscribed.each do |directory|
        items_from_all_feeds.select do |item|
          directory.regexp.match "#{item.summary} #{item.title}"
        end.each do |item|
          torrent = Torrent.new(status: 'remote', url: item.link, content_directory: directory)
          if torrent.save
            created << torrent
          else
            logger.info "sync - could not create Torrent from #{item}: #{torrent.errors.full_messages.join(',')}"
          end
        end
      end
      created.each(&:fetch!).each(&:start!)
    end
  end

  def items_from_all_feeds
    @items ||= Feed.all.map(&:items).flatten
  end

end
