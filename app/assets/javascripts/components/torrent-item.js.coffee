Cataract.TorrentItemComponent = Ember.Component.extend
  classNames: [
    'torrent'
    'row'
    'list-group-item'
    'clearfix'
  ]
  classNameBindings: [
    'active'
    'isCollapsed:collapsed:expanded'
  ]
  tagName: 'li'
  activeBinding: 'childViews.firstObject.active'
  isCollapsed: true
  isShowingFiles: false

  click: (e) ->
    unless $(e.target).is('a,button')
      @toggleProperty 'isCollapsed'

  isNotCollapsed: Ember.computed.not 'isCollapsed'
  showPayload: Ember.computed.and 'content.payloadPresent', 'isNotCollapsed'


  # just forward from torrent-transfer
  startAction: 'startTorrent'
  stopAction: 'stopTorrent'
  dialogAction: 'openModal'
  actions:
    start:  (t)-> @sendAction 'startAction', t
    stop:   (t)-> @sendAction 'stopAction', t
    dialog: (t)-> @sendAction 'dialogAction', t, @get('content')
    toggleFiles: ->
      @toggleProperty 'isShowingFiles'
      false
