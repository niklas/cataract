class WatchlistItem < ActionWebService::Struct
  member :id, :int
  member :progress, :float
  member :status, :string
  member :title, :string
  member :rate_up, :float
  member :rate_down, :float
  member :seeds, :int
  member :peers, :int
  member :message, :string

  def self.from_torrent(t)
    new :id => t.id, 
        :progress => t.percent_done, 
        :status => t.status,
        :title => t.nice_title,
        :rate_up => t.rate_up,
        :rate_down => t.rate_down,
        :seeds => t.seeds,
        :peers => t.peers,
        :message => t.download_status
  end
end

class BackendApi < ActionWebService::API::Base
  api_method :watchlist, 
             :returns => [[WatchlistItem]]
  api_method :find_torrent_by_id,
             :returns => [Torrent],
             :expects => [:int]
end

