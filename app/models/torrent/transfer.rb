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
      update_attribute(:status, :paused)
      log('was paused')
    end
  end

  def start!
    event_from [:paused, :archived, :new] do 
      self.load!  unless paused?
      remote.start! self
      update_attribute(:status, :running)
      log('started')
    end
  end

  def stop!
    event_from [:paused, :running] do
      remote.stop!
      remote.close!
      remote.erase! # WARNING! will delete the torrent file
      finally_stop!
      log('was stopped')
    end
  end

  def finally_stop!
    update_attribute(:status, :archived)
  end

end
