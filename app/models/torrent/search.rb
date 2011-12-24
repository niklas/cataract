class Torrent
  def self.search(params={})
    Search.new(params)
  end

  class Search < HashWithIndifferentAccess
    States = %w(running archived)
    def results
      results = Torrent.scoped
      if status.present?
        results = results.by_status( status )
      end
      results
    end

    def status
      self[:status] ||= States.first
    end
  end
end
