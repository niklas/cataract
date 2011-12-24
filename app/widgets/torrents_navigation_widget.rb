class TorrentsNavigationWidget < JqueryMobile::Widget

  def display
    @search = Torrent.search(params)
    render
  end

end
