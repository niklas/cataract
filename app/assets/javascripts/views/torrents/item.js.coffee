Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents_item'
  classNames: ['torrent']
  tagName: 'li'
  toggleShowing: ->
    console.debug @get('isShowing')
    @set( 'isShowing', ! @get('isShowing'))

