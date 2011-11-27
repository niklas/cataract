class TorrentWidget < JqueryMobile::Widget

  def details(torrent)
    @torrent = torrent
    render
  end

end
