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
    transfer = torrent.store.createRecord Cataract.Transfer, torrent_id: torrent.get('id')
    true
  stop: (event) ->
    if transfer = @get('context.transfer')
      transfer.deleteRecord()
    true

  click: (event) ->
    @toggleExpand(event)
    torrent = @get('context')
    torrent.store.find Cataract.Payload, torrent.get('id')
    false


