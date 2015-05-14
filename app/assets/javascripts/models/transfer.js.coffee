attr = DS.attr
Cataract.Transfer = DS.Model.extend
  progress: attr 'number'
  upRate: attr 'number'
  downRate: attr 'number'
  eta: attr 'string'
  torrent: DS.belongsTo('torrent')
  active: attr 'boolean'
  infoHash: attr 'string'

  isFinished: Ember.computed 'progress', ->
    @get('progress') is 100

  isUploading: Ember.computed 'upRate', ->
    @get('upRate') > 0

  isDownloading: Ember.computed 'isFinished', 'downRate', ->
    !@get('isFinished') and @get('downRate') > 0

Cataract.Transfer.reopenClass
  url: 'transfer' # Emu create param
