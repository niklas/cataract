Cataract.TorrentTransferComponent = Ember.Component.extend
  startAction: 'start'
  stopAction: 'stop'

  actions:
    start: (t)-> @sendAction 'startAction', t
    stop:  (t)-> @sendAction 'stopAction', t
