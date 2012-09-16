class Torrent
  STATES = [
    :running,
    :paused,
    :fetching,
    :new,
    :archived,
    :remote,
    :invalid,
    :moving,
    :missing
  ]

  def self.by_status(status)
    status = status.to_sym
    unless STATES.include?(status)
      raise ArgumentError, "unknown status: #{status}"
    end
    where(:status => status)
  end

  # lets simulate the state machine
  def current_state
    (self.status ||= guess_state).to_sym
  end
  def status=(new_status)
    write_attribute :status, new_status.to_s
  end
  def self.states
    STATES
  end

  STATES.each do |st|
    define_method "#{st.to_s}?" do
      current_state == st
    end
  end

  validates_inclusion_of :current_state, :in => STATES

  def local?
    archived? or running? or paused?
  end

  def in_rtorrent?
    remote.state && true
  rescue NotRunning, HasNoInfoHash
    false
  end

  def status_from_rtorrent
    (remote.state ==  1 ? 'running' : 'paused')
  end

  def update_state!(new_state)
    self.status = new_state
    save!
  end

  # returns the guessed status by attributes
  def guess_state
    if file_exists?
      :archived # TODO review status_from_rtorrent
    else
      if url.blank?
        :new
      else
        :remote
      end
    end
  end

  on_refresh :refresh_status
  def refresh_status
    case status
    when 'running'
      transfer.fetch! [:open?]
      unless open?
        Rails.logger.debug "#{self} was running, but not open anymore. archiving"
        self.status = :archived
      end
    end
  rescue Torrent::RTorrent::Offline
    # ignore
  end

 private

  # TODO call this during refresh
  # Will try to get status from rtorrent and stop the torrent
  # if it's not open/active (in case) of and rtorrent restart etc.
  def check_if_status_is_up_to_date
    good = case current_state
           when :running
             remote.active?
           when :paused
             remote.open?
           else 
             true
           end
    return good
  rescue NotRunning, HasNoInfoHash 
    finally_stop!           # hmm
  end

  class InvalidSourceState < RuntimeError; end

  def event_from(old_states=[])
    old_states = [old_states] unless old_states.is_a? Array
    if old_states.empty? || old_states.include?(current_state)
      begin
        yield
      rescue NotRunning
        finally_stop!
      rescue HasNoInfoHash
        update_attribute(:status,:invalid)
        reload
      end
    else
      raise InvalidSourceState, "#{current_state} is not a valid state for this transition"
    end
  end
end
