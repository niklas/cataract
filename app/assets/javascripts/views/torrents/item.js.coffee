Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'templates/torrents/item'
  classNames: ['torrent']
  tagName: 'li'
  mouseDown: (evt) ->
    console.log "you clicked #{@get('torrent')}"

