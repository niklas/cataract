Cataract.Torrent = Ember.Object.extend
  title: null
  percent: 0
  info_hash: null
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')
  percentStyle: (->
    "width: #{@get('percent')}%"
  ).property('percent')

