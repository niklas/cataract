class ExtractTorrentsFromAbstractFeed
  include Interactor

  def call
    feed = context.abstract_feed
    if feed
      found = feed.items

      if found && !found.empty?

        context.torrents = found.map do |r|
          RemoteTorrent.new(
            title: r.title,
            uri:   r.item.enclosure.url
          ).tap do |t|
            unless t.valid?
              context.fail! message: "Could not build torrent: #{t.errors.full_messages.to_sentence}"
            end
          end
        end
      else
        context.torrents = []
      end
    else
      context.fail! message: 'need an abstract feed'
    end
  end
end
