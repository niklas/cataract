class SlimTorrent < ActionWebService::Struct
  member :id, :int
  member :percent_done, :float
  member :status, :string
end

class BackendApi < ActionWebService::API::Base
  api_method :watchlist, 
             :returns => [[Torrent]]
  api_method :update_watchlist, 
             :returns => [[SlimTorrent]]
  api_method :find_torrent_by_id,
             :returns => [Torrent],
             :expects => [:int]
end

