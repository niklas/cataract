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
            uri:   r.link
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
      context.fail! message: 'need an abstract feed'
    end
  end
end
