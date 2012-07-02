class Torrent

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
    event_from [:paused, :archived, :new] do 
      ensure_content_directory
      self.start_automatically = false
      self.load!  unless paused?
      remote.start! self
      update_state! :running
      log('started')
    end
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

  def progress
    (100.0 * completed_bytes.to_f / size_bytes.to_f).to_i
  rescue FloatDomainError
    0
  end

  def left_seconds
    left_bytes.to_f / down_rate.to_f
  end

  def left_bytes
    size_bytes.to_i - completed_bytes.to_i
  end

end
