class Torrent
  def self.search(params={})
    Search.new(params)
  end

  class Search < HashWithIndifferentAccess
    States = [:running, :archived]
    def results
      results = Torrent.scoped
      if status.present?
        results = results.by_status( status )
      end
      results
    end

    def status
      self[:status]
    end
  end
end
