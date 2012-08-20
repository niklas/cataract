Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents_item'
  classNames: ['torrent']
  tagName: 'li'
  toggleShowing: (event) ->
    torrent = @get('context')
    torrent.set( 'isShowing', ! torrent.get('isShowing'))

  # FIXME how to do RESTful member actions only touching the object on the server?
  #       we could Torrent has_one/belongs_to Transfer, can hold transfer values in there, too
  start: (event) ->
    torrent = @get('context')
    Cataract.store.adapter.ajax torrent.get('transferURL'), 'POST', success: (json) -> torrent.setProperties(json.torrent)
    true
  stop: (event) ->
    torrent = @get('context')
    Cataract.store.adapter.ajax torrent.get('transferURL'), 'DELETE', success: (json) -> torrent.setProperties(json.torrent)
    true

