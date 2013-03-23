class Torrent
  attr_accessor :transfer_id # for ember-data

  def self.running_or_listed(ids)
    if ids.respond_to?(:split)
      ids = ids.split(',')
    end
    if ids.blank?
      by_status('running')
    else
      where('status = ? OR id in (?)', 'running', ids)
    end
  end

  def startable?
    archived? or paused?
  end

  def stoppable?
    running? or paused?
  end

  def pause!
    event_from :running do 
      remote.stop!
      update_state! :paused
      log('was paused')
    end
  end

  def start!
    fetch!
    ensure_content_directory_exists
    self.start_automatically = false
    self.load! unless paused?
    remote.start_and_wait! self
    update_state! :running
    log('started')
  rescue ContentDirectoryMissing => e
    log('could not start: no content directory available')
  end

  def stop!
    event_from [:paused, :running] do
      remote.stop! self
      remote.close! self
      remote.erase! self # WARNING! will delete the torrent file
      finally_stop!
      log('was stopped')
    end
  end

  # same as #stop!, but does not raise any exceptions
  def stop
    remote.stop! self
    remote.close! self
    remote.erase! self # WARNING! will delete the torrent file
    finally_stop!
    log('was stopped')
  rescue StandardError
  end

  def finally_stop!
    update_state! :archived
  end

end
