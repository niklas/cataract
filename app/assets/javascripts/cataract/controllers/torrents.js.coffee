Cataract.torrentsController = Ember.ArrayController.create
  content: [ ]
  createTorrent: (attrs) ->
    torrent = Cataract.Torrent.create attrs
    @pushObject torrent
  refresh: ->
    $.getJSON "torrents.json", (data) ->
      for item in data
        Cataract.torrentsController.createTorrent item
