class Torrent
  def self.search(params={})
    Search.new(params)
  end

  class Search < HashWithIndifferentAccess
    extend ActiveModel::Naming
    States = %w(running archived remote)
    def results
      results = Torrent.scoped

      if has_key?(:status)
        results = results.by_status( status )
      end

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

    def query
      self[:query]
    end

    include ActiveModel::AttributeMethods
    def attributes
      self
    end


    include ActiveModel::Conversion
    def persisted?
      false
    end
  end
end
