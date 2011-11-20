class TorrentsHeaderWidget < JqueryMobile::Widget

  def display
    @search = Torrent.search(params)
    @status = @search.status
    render
  end

end
