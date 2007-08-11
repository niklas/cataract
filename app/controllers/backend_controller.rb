class BackendController < ApplicationController
  wsdl_service_name 'Backend'
  web_service_dispatching_mode :direct

  before_filter :login_required

  def watchlist
    current_user.torrents
  end

  def update_watchlist
    watchlist.map do |t|
      SlimTorrent.from_torrent t
    end
  end

  def find_torrent_by_id(tid)
    Torrent.find tid
  end
end
