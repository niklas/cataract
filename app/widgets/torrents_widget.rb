class TorrentsWidget < JqueryMobile::Widget
  helper :torrents

  def display
    @search = Torrent.search(params)
    @torrents = @search.results
    render
  end

end
