class SearchTorrentsOnline
  include Interactor

  def call
    filter = context.filter
    if filter && filter.present?

      kat = Kat.search filter, categories: 'tv'

      context.torrents = kat.results.map do |r|
      end
    else
      context.fail! message: 'must have #filter set'
    end
  end
end

