class BackendController < ApplicationController
  wsdl_service_name 'Backend'
  web_service_dispatching_mode :direct

  before_filter :login_required

  def watchlist
    current_user.torrents.map { |t| WatchlistItem.from_torrent t }
  end

  def find_torrent_by_id(tid)
    Torrent.find tid
  end
end
