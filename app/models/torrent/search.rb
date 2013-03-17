class Torrent

  def self.new_search(params={})
    Search.new(params)
  end

  class Search < HashWithIndifferentAccess
    include ActiveAttr::Model
    include ActiveAttr::AttributeDefaults

    attribute :status
    attribute :terms
    attribute :page
    attribute :per, default: 50
    attribute :directory_id

    States = %w(all recent running archived remote)
    FullTextFields = %w(title filename)

    def initialize(*a)
      super
      self.status ||= States.first
    end

    def results
      results = Torrent.scoped

      if status? && !status.in?(['all', 'recent'])
        results = results.by_status( status )
      end

      if terms?
        results = results.where terms_like_statement, like_terms
      end

      if directory_id?
        results = results.where(content_directory_id: directory_id).order('title, filename')
      else
        results = results.order("created_at DESC")
      end

      if per?
        results.page(page || 1).per(per)
      else
        results
      end

    end

    def to_params
      present_attributes.merge(only_path: true)
    end

    def present_attributes
      attributes.slice(*%w[status terms page directory_id]).reject {|k,v| v.blank? }
    end

    def translated_criteria
      present_attributes.map do |attr, value|
        if attr == 'directory_id'
          { 'directory' => t("search_title.directory", value: directory.name) }
        else
          { attr => t("search_title.#{attr}", value: value) }
        end   # VV slice sorts the hash for us. Shows only translated attributes, no fallback!
      end.inject(&:merge)
    end

    def title
      translated_criteria.slice(*t("search_title").keys.map(&:to_s)).values.join(' ')
    end

    def paginating?
      page? && page.to_i > 1
    end

    private

    def i18n_scope
      "#{Torrent.i18n_scope}.attributes.torrent"
    end

    def t(key, opts={})
      I18n.translate(key, opts.merge(scope: i18n_scope))
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

    def directory
      Directory.find(directory_id)
    end
  end
end
