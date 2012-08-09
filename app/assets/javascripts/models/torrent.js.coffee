Cataract.Torrent = DS.Model.extend
  title: DS.attr 'string'
  percent: DS.attr 'number'
  info_hash: DS.attr 'string'
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')
  percentStyle: (->
    "width: #{@get('percent')}%"
  ).property('percent')

Cataract.Torrent.reopenClass
  url: 'torrent'
