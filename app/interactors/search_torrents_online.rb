class SearchTorrentsOnline
  include Interactor
  include InteractorLoggable

  def call
    filter = context.filter
    page   = context.page || 0
    if filter && filter.present?

      kat = Kat.search filter, categories: 'tv'
      kat.search(page)

      found = kat.results[page]

      if found
        debug { "#{self.class} searched for #{filter.inspect}, got #{found.length}+ results" }
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
