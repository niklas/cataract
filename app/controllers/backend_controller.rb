class BackendController < ApplicationController
#  wsdl_service_name 'Backend'
#  web_service_dispatching_mode :direct

  def watchlist
    Torrent.find :all, :limit => 3
  end

  def update_watchlist
    watchlist.map do |t|
      SlimTorrent.new :id => t.id, :percent_done => t.percent_done, :status => t.status 
    end
  end

  def find_torrent_by_id(tid)
    Torrent.find tid
  end
end
