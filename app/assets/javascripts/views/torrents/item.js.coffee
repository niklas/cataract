Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents/item'
  classNames: ['torrent']
  classNameBindings: ['active']
  tagName: 'li'
  click: ->
    Cataract.Router.router.transitionTo 'torrent', @get('content')
  activeBinding: 'childViews.firstObject.active'
