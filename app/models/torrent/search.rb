class Torrent

  def self.new_search(params={})
    Search.new(params)
  end

  class Search < HashWithIndifferentAccess
    extend ActiveModel::Naming
    States = %w(running archived remote)
    FullTextFields = %w(title filename)

    def results
      results = Torrent.scoped

      if has_key?(:status)
        results = results.by_status( status )
      end

      if has_key?(:terms) && terms.present?
        results = results.where terms_like_statement, like_terms
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

    private

    def stripped_terms
      terms.split.map(&:strip).reject(&:blank?)
    end

    def like_terms
      '%' + stripped_terms.join('%') + '%'
    end

    def terms_fields
      FullTextFields.map do |field|
        "COALESCE(#{field}, '')"
      end.join('||')
    end

    def terms_like_statement
      "(#{terms_fields}) ILIKE ?"
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
