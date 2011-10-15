class Torrent
  STATES = [:running,:paused,:fetching,:new,:archived,:remote,:invalid,:moving]
  # lets simulate the state machine
  def current_state
    status ? status.to_sym : :nostatus
  end
  def status=(new_status)
    self[:status] = new_status.to_s
  end
  def self.states
    STATES
  end

  STATES.each do |st|
    define_method "#{st.to_s}?" do
      current_state == st
    end
  end

  def startable?
    archived? or paused?
  end

  def stoppable?
    running? or paused?
  end

  def local?
    archived? or running? or paused?
  end

  def in_rtorrent?
    remote.state && true
  rescue TorrentNotRunning, TorrentHasNoInfoHash
    false
  end

  def status_from_rtorrent
    (remote.state ==  1 ? 'running' : 'paused')
  end

  def set_status_on_create
    self.status = 'new'
    self.status = 'remote' unless url.blank?
    self.status = 'archived' if file_exists?(:archived)
  end
  before_validation :set_status_on_create, :on => :create
  
  def pause!
    event_from :running do 
      remote.stop!
      update_attribute(:status, :paused)
      log('was paused')
    end
  end

  def start!
    event_from [:paused, :archived, :new] do 
      unless paused?
        # copy the file because rtorrent deletes file on #stop!
        moveto( :running, :copy => true )
        remote.load(self.fullpath(:running))
        remote.directory = download_path
      end
      remote.start!
      update_attribute(:status, :running)
      log('was started')
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

  def fetch!
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
    rescue TorrentNotRunning, TorrentHasNoInfoHash
      new_status = auto_status
    end
    status = new_status
  end

 private
  def filepath_by_status(stat)
    return if filename.blank?
    case stat.to_sym
    when :fetching 
      File.join(Settings.history_dir, filename) + '.fetching'
    when :running  
      File.join(Settings.torrent_dir, 'active', filename)
    when :paused   
      File.join(Settings.torrent_dir, 'active', filename)
    when :new      
      File.join(Settings.torrent_dir, filename)
    when :archived 
      File.join(Settings.history_dir, filename)
    when :remote   
      ''
    else
      nil
    end
  end

  def status_by_filepath
    STATES.find(:invalid) do |stat|
      path = filepath_by_status(stat)
      path.blank? || File.exists?(path)
    end
  rescue NoMethodError
    return :invalid
  end

  def find_file
    STATES.map {|s| filepath_by_status(s) }.find { |p| File.exists?(p) }
  end

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
  rescue TorrentNotRunning, TorrentHasNoInfoHash 
    finally_stop!           # hmm
  end


  def event_from(old_states=[])
    old_states = [old_states] unless old_states.is_a? Array
    if old_states.empty? || old_states.include?(current_state)
      begin
        yield
      rescue TorrentNotRunning
        finally_stop!
      rescue TorrentHasNoInfoHash
        update_attribute(:status,:invalid)
        reload
      end
    else
      raise RuntimeError, "#{current_state} is not a valid state for this transition"
    end
  end
end
