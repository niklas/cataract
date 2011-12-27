module RTorrentSpecHelper

  def rtorrent_socket_path
    Rails.root/'tmp'/'sockets'/'rtorrent_test'
  end

  def start_rtorrent(seconds=5)
    Torrent::RTorrent.online!
    FileUtils.rm rtorrent_socket_path if rtorrent_socket_path.exist?

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
    end
  rescue Timeout::Error => e
    STDERR.puts "could not start rtorrent, commands:\n#{rtorrent_command.inspect}"
    raise e
  end

  def stop_rtorrent
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
      '-o', "scgi_local=#{rtorrent_socket_path}"
    ]
  end

end

RSpec.configure do |config|
  config.include RTorrentSpecHelper
end
