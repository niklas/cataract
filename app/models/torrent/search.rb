class Torrent
  def self.search(params={})
    Search.new(params).results
  end

  class Search < HashWithIndifferentAccess
    def results
      results = Torrent.scoped
      if has_key?(:by_status)
        results = results.by_status( self[:by_status] )
      end
      results
    end
  end
end
