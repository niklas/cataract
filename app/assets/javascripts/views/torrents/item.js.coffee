Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents/item'
  classNames: ['torrent']
  tagName: 'li'
  isExpanded: false
  toggleExpand: (event) ->
    @set( 'isExpanded', ! @get('isExpanded'))
    false

  start: (event) ->
    torrent = @get('context')
    torrent.store.createRecord Cataract.Transfer, id: torrent.get('id')
    torrent.store.commit()
    false

  stop: (event) ->
    if transfer = @get('context.transfer')
      transfer.deleteRecord()
      transfer.store.commit()
    false

  click: (event) ->
    @toggleExpand(event)
    torrent = @get('context')
    torrent.store.find Cataract.Payload, torrent.get('id')
    false


