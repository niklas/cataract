module RTorrentSpecHelper

  def socket_path
    Rails.root/'tmp'/'sockets'
  end

  def rtorrent_log_path
    Rails.root/'log'/'rtorrent-test.log'
  end

  def rtorrent_socket_path
    socket_path/'rtorrent_test'
  end

  def start_rtorrent(seconds=15)
    Cataract.transfer_adapter_class.online!
    FileUtils.rm rtorrent_socket_path if rtorrent_socket_path.exist?
    FileUtils.mkdir_p socket_path unless socket_path.exist?

    if @rtorrent_pid = Process.spawn(*rtorrent_command)
      Process.detach @rtorrent_pid
      Rails.logger.debug "spawned rtorrent with pid:#{@rtorrent_pid}, waiting #{seconds}s"
      Timeout.timeout(seconds) do
        while !rtorrent_socket_path.exist?
          sleep 0.1
        end
      end
      Torrent.reset_remote!
      Torrent.stub(:rtorrent_socket_path).and_return(rtorrent_socket_path)
    else
      raise "could not start rtorrent"
    end
  rescue Timeout::Error => e
    STDERR.puts "could not start rtorrent, commands:\n#{rtorrent_command.inspect}"
    raise e
  end

  def stop_rtorrent
    Cataract.transfer_adapter_class.offline!
    if @rtorrent_pid
      Rails.logger.debug "killing rtorrent with pid: #{@rtorrent_pid}"
      Process.kill 'TERM', @rtorrent_pid
      @rtorrent_pid = nil
    end
  end

  def rtorrent_command
    [
      'screen', '-DmUS', 'rtorrent_cataract_test',
      'rtorrent',
      '-n', # do not load user's rc
      '-o', "scgi_local=#{rtorrent_socket_path}",
      '-O', %Q~log.open_file="rtorrent",#{rtorrent_log_path}~,
      '-O', %Q~log.add_output="debug","rtorrent"~,
      '-O', %Q~log.add_output="storage_info","rtorrent"~,
      '-o', 'download_rate=1',
      '-o', 'upload_rate=1',
      '-o', 'max_uploads=2',
    ]
  end

end

RSpec.configure do |config|
  config.include RTorrentSpecHelper
end
