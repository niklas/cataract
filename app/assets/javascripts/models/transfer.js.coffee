Cataract.Transfer = DS.Model.extend
  progress: DS.attr 'number'
  upRate: DS.attr 'string'
  downRate: DS.attr 'string'
  eta: DS.attr 'string'
  progressStyle: Ember.computed ->
    "width: #{@get('progress')}%"
  .property('progress')
  downloading: Ember.computed ->
    @get('progress') != 100 and parseInt(@get('downRate')) > 0
  .property('progress', 'downRate')
  finished: Ember.computed ->
    @get('progress') == 100
  .property('progress')
