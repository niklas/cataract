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
          unless filepath.valid_encoding?
            n = filepath.scrub
            File.rename filepath, n
            filepath = n
          end
          torrent = Torrent.new(status: 'new', file: File.open(filepath))
          if torrent.save
            created << torrent 
          else
            # FIXME do not depend on English locale
            if torrent.errors[:filename].include?('has already been taken')
              if md5(filepath) == md5(torrent.file.path)
                File.rm_f filepath
              end
            else
              logger.info "sync - could not create Torrent from #{filepath}: #{torrent.errors.full_messages.join(',')}"
            end
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
          directory.regexp.match item.title
        end.each do |item|
          torrent = Torrent.new(status: 'remote', url: item.uri, content_directory: directory, title: item.title)
          if torrent.save
            created << torrent
          else
            logger.info "sync - could not create Torrent from #{item}: #{torrent.errors.full_messages.join(',')}"
          end
        end
      end
      created.each do |t|
        begin
          t.fetch!
          t.save!
          t.start!
        rescue Torrent::RTorrent::CouldNotFindInfoHash => e
        end
      end
    end
  end

  def items_from_all_feeds
    @items ||= Feed.all.map do |feed|
      res = FetchTorrentsFromRSS.call feed: feed
      if res.success?
        res.torrents
      else
        [] # ignore failures
      end
    end.flatten
  end

  def md5(path)
    Digest::MD5.hexdigest(File.read path)
  rescue StandardError
    return rand # never the same *crosses fingers*
  end

end
