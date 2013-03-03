Cataract.ItemTorrentView = Ember.View.extend
  templateName: 'torrents/item'
  classNames: ['torrent']
  tagName: 'li'
  click: ->
    Cataract.Router.router.transitionTo 'torrent', @get('content')
  didInsertElement: ->
    @storeOffset()
    @set 'resizeHandler', => @storeOffset()
    jQuery(window).bind 'resize', @get('resizeHandler')

  willDestroyElement: ->
    jQuery(window).unbind 'resize', @get('resizeHandler')
    @set 'resizeHandler', null

  storeOffset: ->
    @get('content').set('offsetInList', @$().position().top)
