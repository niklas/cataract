Cataract.Transfer = Emu.Model.extend
  progress: Emu.field 'number'
  upRate: Emu.field 'string'
  downRate: Emu.field 'string'
  eta: Emu.field 'string'
  torrentId: Emu.field 'number' # FIXME is not set by serializer
  progressStyle: Ember.computed ->
    "width: #{@get('progress')}%"
  .property('progress')
  downloading: Ember.computed ->
    @get('progress') != 100 and parseInt(@get('downRate')) > 0
  .property('progress', 'downRate')
  finished: Ember.computed ->
    @get('progress') == 100
  .property('progress')
  active: Emu.field 'boolean'

  # ember-emu specific for nested URL
  parent: Emu.belongsTo('Cataract.Torrent', key: 'torrentId')

Cataract.Transfer.reopenClass
  url: 'transfer'
