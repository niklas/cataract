Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents_item'
  classNames: ['torrent']
  tagName: 'li'
  mouseDown: (evt) ->
    console.log "you clicked #{@get('torrent')}"

