Cataract.Transfer = DS.Model.extend
  progress: DS.attr 'number'
  up_rate: DS.attr 'string'
  down_rate: DS.attr 'string'
  eta: DS.attr 'string'
  progressStyle: (->
    "width: #{@get('progress')}%"
  ).property('progress')

