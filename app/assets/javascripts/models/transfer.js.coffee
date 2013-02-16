Cataract.Transfer = DS.Model.extend
  progress: DS.attr 'number'
  upRate: DS.attr 'string'
  downRate: DS.attr 'string'
  eta: DS.attr 'string'
  progressStyle: (->
    "width: #{@get('progress')}%"
  ).property('progress')
