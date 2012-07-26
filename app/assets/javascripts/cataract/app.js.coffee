jQuery ->
  window.Cataract = Ember.Application.create
    rootElement: '#container'

  Cataract.Hello = Ember.View.create
    templateName: 'say-hello'
    name: "Spaghettimonster"

  Cataract.Hello.appendTo('#container')

  Cataract.Torrents = Ember.Object.create
    torrents: [
      { title: "One" },
      { title: "Two" }
    ]

  Cataract.TorrentsList = Ember.View.create
    templateName: 'torrents-list'
    torrentsBinding: 'Cataract.Torrents.torrents'

  Cataract.TorrentsList.appendTo('#container')
