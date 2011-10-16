class Torrent
  RTORRENT_METHODS = [:up_rate, :up_total, :down_rate, :down_total, :size_bytes, :message, :completed_bytes, :open?, :active?]

  def method_missing_with_xml_rpc(m, *args, &blk)
    if RTORRENT_METHODS.include?(m.to_sym) and remote
      remote.send m, *args, &blk
    else
      method_missing_without_xml_rpc m, *args, &blk
    end
  rescue TorrentNotRunning => e
    finally_stop! unless archived?
    raise e
  rescue TorrentHasNoInfoHash => e
    finally_stop!
    return
  end
  alias_method_chain :method_missing, :xml_rpc

  def self.rtorrent
    RTorrentProxy.remote
  end

  def rtorrent
    self.class.rtorrent
  end

  def remote
    @remote ||= RTorrentProxy.new(self,rtorrent)
  end


end
