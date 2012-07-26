jQuery ->
  window.Cataract = Ember.Application.create
    rootElement: '#container'

  Cataract.Torrent = Ember.Object.extend
    title: null

  Cataract.Torrents = Ember.ArrayController.create
    content: [ ]
    createTorrent: (attrs) ->
      torrent = Cataract.Torrent.create attrs
      @pushObject torrent
    refresh: ->
      $.getJSON "torrents.json", (data) ->
        for item in data
          Cataract.Torrents.createTorrent item


  Cataract.TorrentItem = Ember.View.extend
    templateName: 'torrent-item'
    mouseDown: (evt) ->
      console.log "you clicked #{@get('content')}"

  Cataract.TorrentsList = Ember.CollectionView.create
    tagName: 'ul'
    classNames: ['torrents']
    itemViewClass: Cataract.TorrentItem
    contentBinding: "Cataract.Torrents"

  Cataract.TorrentsList.appendTo('#container')
  Cataract.Torrents.refresh()
