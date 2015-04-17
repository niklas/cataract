Cataract.TorrentItemComponent = Ember.Component.extend
  classNames: [
    'torrent'
    'row'
    'list-group-item'
    'clearfix'
  ]
  classNameBindings: [
    'isCollapsed:collapsed:expanded'
  ]
  tagName: 'li'
  isCollapsed: true
  isShowingFiles: false

  click: (e) ->
    unless $(e.target).closest('a,button').length > 0
      @toggleProperty 'isCollapsed'

  hasFiles: Ember.computed.notEmpty 'content.payload.filenames'
  isNotCollapsed: Ember.computed.not 'isCollapsed'
  showPayload: Ember.computed.and 'content.payloadExists', 'isNotCollapsed'


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
