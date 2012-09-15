Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents/item'
  classNames: ['torrent']
  tagName: 'li'
  toggleExpand: (event) ->
    torrent = @get('context')
    torrent.set( 'isExpanded', ! torrent.get('isExpanded'))

  # FIXME how to do RESTful member actions only touching the object on the server?
  #       we could Torrent has_one/belongs_to Transfer, can hold transfer values in there, too
  start: (event) ->
    torrent = @get('context')
    torrent.store.adapter.ajax torrent.get('transferURL'), 'POST', success: (json) -> torrent.setProperties(json.torrent)
    true
  stop: (event) ->
    torrent = @get('context')
    torrent.store.adapter.ajax torrent.get('transferURL'), 'DELETE', success: (json) -> torrent.setProperties(json.torrent)
    true

  click: (event) ->
    @toggleExpand(event)
    torrent = @get('context')
    torrent.store.find Cataract.Payload, torrent.get('id')


