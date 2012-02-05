class Torrent
  def self.search(params={})
    Search.new(params)
  end

  def self.with_terms(terms)
    term = terms.strip.split.first
    where('title ILIKE ?', "%#{term}%")
  end

  class Search < HashWithIndifferentAccess
    extend ActiveModel::Naming
    States = %w(running archived remote)
    def results
      results = Torrent.scoped

      if has_key?(:status)
        results = results.by_status( status )
      end

      if has_key?(:terms) && terms.present?
        results = results.with_terms( terms )
      end

      results.order("created_at DESC").page(page || 1).per(per)
    end

    def status
      self[:status] ||= States.first
    end

    def page
      self[:page]
    end

    def per
      self[:per] ||= 20
    end

    def terms
      self[:terms]
    end

    def page?
      has_key?(:page)
    end

    include ActiveModel::AttributeMethods
    def attributes
      self.slice(:status, :page, :per, :terms)
    end


    include ActiveModel::Conversion
    def persisted?
      false
    end
  end
end
