class Torrent
  # make sure that a copy of this torrent is in the archive
  def assure_file_in_archive!
    if file_exists?
      moveto( :archived, :copy => true) unless file_exists?(:archived)
    elsif !(real_path = remote.tied_to_file).blank?
      copy( real_path, fullpath(:archived) ) unless file_exists?(:archived)
      copy( real_path, fullpath )
    elsif !(real_path = find_file).blank?
      copy( real_path, fullpath(:archived) ) unless file_exists?(:archived)
      copy( real_path, fullpath )
    end
  rescue NotRunning, HasNoInfoHash
    false
  rescue Exception => e
    errors.add :filename, "^error while assure_file_in_archive: #{e.to_s}"
    false
  end

  def sync
    sync! if needs_to_be_synced?
  end

  def sync!
    set_metainfo && synced_at = Time.now
  end


  SYNC_INTERVAL = 1.day unless defined? SYNC_INTERVAL
  def needs_to_be_synced?
    synched_at.blank? || (Time.now - synched_at > SYNC_INTERVAL)
  end

  # checks all torrents in database
  #  * exists the file?
  #  * reads the hash if it is not already in the db
  #  * ..
  def self.sync
    logger.debug { "sync start" }
    detect_in_watched_directories
    #find_all_outdated.each do |t|
    #  t.sync!
    #  unless t.valid?
    #    # FIXME beware!! check validations first
    #    #t.destroy
    #    logger.info "Torrent ##{t.id} seems to be invalid. We will destroy them! (Worf, 237x)"
    #  else
    #    t.save
    #  end
    #end
  end
  def self.find_all_outdated
    find(:all, 
         :conditions => ['synched_at IS NULL OR synched_at < ?', Time.now - SYNC_INTERVAL]
        )
  end

  # looks in the torrent_dir for new torrent files and creates them
  def self.detect_in_watched_directories
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

  # Looks into rtorrent's download_list and adds the running torrents to the db
  # unless they exist already
  # FIXME: what if somebody adds a torrent somewhere on the filesystem?
  # FIXME: rtorrent does not give us the torrent's filename, just the name of hte directory
  # => gggrml!
  def self.recognize_running
    saved = []
    hashes = rtorrent.download_list
    hashes.each do |hash|
      if torrent = find_by_info_hash(hash)
        torrent.filename ||= torrent.remote.base_filename + '.torrent'
        torrent.status = torrent.status_from_rtorrent unless torrent.status =~ /^running|paused$/
      else
        torrent = new(:info_hash => hash)
        torrent.status = torrent.status_from_rtorrent
        torrent.filename = torrent.remote.base_filename + '.torrent'
      end
      torrent.assure_file_in_archive!
      torrent.moveto(:running,:copy => true)
      if torrent.save
        saved << torrent
      end
    end
    saved
  end
end
