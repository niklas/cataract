Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents/item'
  classNames: ['torrent']
  tagName: 'li'
  click: ->
    Cataract.Router.router.transitionTo 'torrent', @get('content')
