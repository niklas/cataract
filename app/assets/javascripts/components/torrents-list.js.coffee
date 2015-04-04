Cataract.TorrentsListComponent = Ember.Component.extend
  content: []
  mode: 'unknown'

  tagName: "ul"
  elementId: "torrents"
  classNames: [
    "torrents"
    "clearfix"
    'list-group'
  ]

  # just forward from torrent-item
  startAction: 'startTorrent'
  stopAction: 'stopTorrent'
  actions:
    startTorrent: (t)-> @sendAction 'startAction', t
    stopTorrent:  (t)-> @sendAction 'stopAction', t

  wantsCircleView: Ember.computed.equal 'mode', 'library'
