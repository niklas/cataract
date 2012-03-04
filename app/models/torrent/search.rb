class Torrent

  def self.new_search(params={})
    Search.new(params)
  end

  class Search < HashWithIndifferentAccess
    include ActiveAttr::Model
    include ActiveAttr::AttributeDefaults
    include Draper::ModelSupport

    attribute :status
    attribute :terms
    attribute :page
    attribute :per, default: 20

    States = %w(all running archived remote)
    FullTextFields = %w(title filename)

    def initialize(*a)
      super
      self.status ||= States.first
    end

    def results
      results = Torrent.scoped

      if status? && status != 'all'
        results = results.by_status( status )
      end

      if terms?
        results = results.where terms_like_statement, like_terms
      end

      results.order("created_at DESC").page(page || 1).per(per)
    end

    def to_params
      attributes.slice(*%w[status terms page]).reject {|k,v| v.blank? }.merge(only_path: true)
    end

    def title
      key = terms?? :status_and_terms : :status
      I18n.translate "search_title.#{key}", status: status, terms: terms, scope: i18n_scope
    end

    private

    def i18n_scope
      "#{Torrent.i18n_scope}.attributes.torrent"
    end

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
  end
end
