attr = DS.attr
Cataract.Transfer = DS.Model.extend
  progress: attr 'number'
  upRate: attr 'string'
  downRate: attr 'string'
  eta: attr 'string'
  torrentId: attr 'number' # FIXME is not set by serializer
  progressStyle: Ember.computed ->
    "width: #{@get('progress')}%"
  .property('progress')
  downloading: Ember.computed ->
    @get('progress') != 100 and parseInt(@get('downRate')) > 0
  .property('progress', 'downRate')
  finished: Ember.computed ->
    @get('progress') == 100
  .property('progress')
  active: attr 'boolean'

Cataract.Transfer.reopenClass
  url: 'transfer' # Emu create param
