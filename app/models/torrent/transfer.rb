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

  def stop
    stop!
  rescue InvalidSourceState
  end

  def finally_stop!
    update_state! :archived
  end

  def progress
    (100.0 * completed_bytes.to_f / size_bytes.to_f).to_i
  rescue FloatDomainError
    0
  end

end
