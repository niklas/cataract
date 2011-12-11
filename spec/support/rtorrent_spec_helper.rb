module RTorrentSpecHelper

  def rtorrent_socket_path
    Rails.root/'tmp'/'sockets'/'rtorrent_test'
  end

  def start_rtorrent(seconds=5)
    FileUtils.rm rtorrent_socket_path if rtorrent_socket_path.exist?

    if @rtorrent_pid = Process.spawn(*rtorrent_command)
      Process.detach @rtorrent_pid
      Rails.logger.debug "spawned rtorrent pid:#{@rtorrent_pid}, waiting #{seconds}s"
      Timeout.timeout(seconds) do
        while !rtorrent_socket_path.exist?
          sleep 0.1
        end
      end
    end
  rescue Timeout::Error => e
    STDERR.puts "could not start rtorrent, commands:\n#{rtorrent_command.inspect}"
    raise e
  end

  def stop_rtorrent
    if @rtorrent_pid
      Process.kill 'TERM', @rtorrent_pid
    end
  end

  def rtorrent_command
    [
      'screen', '-DmUS', 'rtorrent_cataract_test',
      'rtorrent',
      '-n', # do not load user's rc
      '-o', "scgi_local=#{rtorrent_socket_path}"
    ]
  end

end

include RTorrentSpecHelper
