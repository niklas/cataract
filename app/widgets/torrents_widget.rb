class TorrentsWidget < Apotomo::Widget
  helper :torrents

  def display
    @torrents = Torrent.search(params)
    render
  end

end
