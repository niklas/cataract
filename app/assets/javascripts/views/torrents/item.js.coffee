Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents/item'
  classNames: ['torrent']
  tagName: 'li'
  click: ->
    Cataract.Router.router.transitionTo 'torrent', @get('content')
  didInsertElement: ->
    # TODO bind the position from top so a browser resize is recognized
    @get('content').set('offsetInList', @$().position().top)
