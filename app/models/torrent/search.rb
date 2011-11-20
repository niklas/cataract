class Torrent
  def self.search(params={})
    Search.new(params).results
  end

  class Search < HashWithIndifferentAccess
    States = [:running, :archived]
    def results
      results = Torrent.scoped
      if has_key?(:status)
        results = results.by_status( self[:status] )
      end
      results
    end
  end
end
