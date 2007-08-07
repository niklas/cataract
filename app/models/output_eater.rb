require 'open3'
class OutputEater
  attr_accessor :verbose

  def initialize(source='flupp',runnable=false)
    @source = source
    @runnable = runnable
    @logfile = '/tmp/cataract_eater.log'
    @verbose = false
    prepare
  end

  def prepare
    # here you insert you own code, run directly after new
  end


  def startup 
    @stop = false
    eater(3)
    teardown
  end

  def stop(io=nil)
    info "stopping the feeder.. "
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
      if @runnable
        info "running #{@source} and reading its input"
        Open3.popen3(@source) do |stdin, stdout, stderr|
          trap "INT" do
            self.stop(stdin)
            @stop = true
          end
          while line = stdout.gets
            process_line(line)
          end
        end
      else
        info "opening #{@source} for input"
        File.open(@source) do |input|
          while line = input.gets
            process_line(line)
          end
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
    filename = attribs.delete(:filename)
    torrent = Torrent.find_by_filename(filename)
    unless torrent
      info "new torrent found: #{filename}'"
      torrent = Torrent.create(:filename => filename)
    end
    torrent.update_attributes(attribs)
    info "#{torrent.percent_done}% (#{torrent.statusmsg}) #{torrent.filename}"
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
        out = "#{self.class}: #{line}"
        f.puts out
        puts line if @verbose
      end
    end
  end
end
