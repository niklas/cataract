class Torrent
  STATES = [:running,:paused,:fetching,:new,:archived,:remote,:invalid,:moving]

  def self.by_status(status)
    status = status.to_sym
    unless STATES.include?(status)
      raise ArgumentError, "unknown status: #{status}"
    end
    where(:status => status)
  end

  # lets simulate the state machine
  def current_state
    status ? status.to_sym : :nostatus
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

  def old_fetch!
    event_from [:remote] do
      update_attribute(:status, :fetching)
      fetch_by_url
      moveto( :archived )
      update_attribute(:status, :archived)
      log('was fetched')
    end
  end

  def fetch_and_start!
    fetch! && start!
  end

  def self.fetch_and_start_by_url(new_url)
    if t = create(:url => new_url, :status => 'remote')
      t.fetch! && t.start!
    end
    t
  end

  def auto_status
    unless file_exists?
      unless url.blank?
        :remote
      else
        status_by_filepath
      end
    else
      status
    end
  end

  def sync_status!
    new_status = 'new'
    begin
      new_status = status_from_rtorrent
    rescue NotRunning, HasNoInfoHash
      new_status = auto_status
    end
    status = new_status
  end

 private

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
