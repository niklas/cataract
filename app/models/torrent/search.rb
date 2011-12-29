class Torrent
  def self.search(params={})
    Search.new(params)
  end

  class Search < HashWithIndifferentAccess
    States = %w(running archived remote)
    def results
      results = Torrent.scoped
      results = results.by_status( status )

      results.order("created_at DESC").page(page).per(per)
    end

    def status
      self[:status] ||= States.first
    end

    def page
      self[:page] ||= 1
    end

    def per
      self[:per] ||= 20
    end
  end
end
