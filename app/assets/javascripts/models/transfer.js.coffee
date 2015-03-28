attr = DS.attr
Cataract.Transfer = DS.Model.extend
  progress: attr 'number'
  upRate: attr 'string'
  downRate: attr 'string'
  eta: attr 'string'
  torrent: DS.belongsTo('torrent')
  active: attr 'boolean'

  isFinished: Ember.computed 'progress', ->
    @get('progress') is 100

  isUploading: Ember.computed 'upRate', ->
    parseInt(@get('upRate')) > 0

  isDownloading: Ember.computed 'isFinished', 'downRate', ->
    !@get('isFinished') and parseInt(@get('downRate')) > 0

Cataract.Transfer.reopenClass
  url: 'transfer' # Emu create param
