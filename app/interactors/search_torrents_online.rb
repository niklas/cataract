class SearchTorrentsOnline
  include Interactor

  def call
    filter = context.filter
    if filter && filter.present?

      kat = Kat.search filter, categories: 'tv'
      kat.search

      found = kat.search(page)

      if found
        context.torrents = found.map do |r|
          RemoteTorrent.new(
            title: r[:title],
            uri:   r[:download],
            size:  r[:size],
            age:   r[:age],
            seeds: r[:seeds],
            magnet: r[:magnet]
          ).tap do |t|
            unless t.valid?
              context.fail! message: "cannot integrate #{r.inspect}"
            end
          end
        end
      else
        context.torrents = []
      end
    else
      context.fail! message: 'must have #filter set'
    end
  end
end

