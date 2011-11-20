class TorrentsWidget < JqueryMobile::Widget
  helper :torrents

  def display
    @torrents = Torrent.search(params)
    render
  end

end
