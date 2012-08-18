Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents_item'
  classNames: ['torrent']
  tagName: 'li'
  toggleShowing: (event) ->
    torrent = @get('context')
    torrent.set( 'isShowing', ! torrent.get('isShowing'))

