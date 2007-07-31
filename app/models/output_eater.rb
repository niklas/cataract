class OutputEater
  def initialize(source='flupp')
    @source = source
    @logfile = 'bt.log'
  end

  def startup 
    @stop = false
    eater(3)
    teardown
  end

  def update_interface
    info "updating the interface"
    sleep 3
  end

  def teardown
    info "quitting..."
    exit
  end

  def eater(some_time=1)
    while not @stop # keeps reading until something other happens
      info "opening #{@source} for input"
      File.open(@source) do |input|
        while line = input.gets
          process_line(line)
        end
      end
      sleep some_time
    end
  end

  def process_line(line)
    line.chomp!
    return if line =~ /^\s*$/

    match_logentry(line) or
    update( match_torrent_entry(line) ) or
    info "EEE: don't know how to process or something went wrong: #{line}\n"
  end

  def match_torrent_entry(line)
    raise 'you must implement YourEater#match_torrent_entry(line)'
  end

  def match_logentry(line)
    raise 'you must implement YourEater#match_logentry(line)'
  end

  def update(attribs)
    return unless attribs
    filename = attribs[:filename]
    torrent = Torrent.find_by_filename(filename)
    unless torrent
      info "WWW: unknown torrent updated, registering: #{filename}'"
      torrent = Torrent.create(:filename => filename)
    end
    torrent.update_attributes(attribs)
  end

  def dropped(filename)
    torrent = Torrent.find_by_filename(filename)
    if torrent
      if @stop
        info "breaking #{filename}"
        torrent.brake 
      else
        info "pausing #{filename}"
        torrent.pause! if torrent.status == 'running'
      end
      torrent.save
    else
      info "WWW: unknown torrent dropped: '#{filename}'"
    end
  end

  def added(filename)
    torrent = Torrent.find_by_filename(filename)
    unless torrent
      info "creating #{filename}"
      torrent = Torrent.create(:filename => filename, :status => :running)
    end
  end

  def info(*args)
    File.open(@logfile,'a+') do |f| 
      args.each do |line|
        f.puts "#{self.class}: #{line}"
      end
    end
  end
end
