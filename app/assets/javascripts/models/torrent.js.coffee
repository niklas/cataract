Cataract.Torrent = DS.Model.extend
  title: DS.attr 'string'
  progress: DS.attr 'number'
  info_hash: DS.attr 'string'
  status: DS.attr 'string'
  up_rate: DS.attr 'string'
  down_rate: DS.attr 'string'
  eta: DS.attr 'string'
  filename: DS.attr 'string'
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')
  contentDirectory: DS.belongsTo('Cataract.Directory')
  contentSize: DS.attr 'number'
  contentFilenames: DS.attr 'staticArray'

  hasContent: (->
    @get('contentFilenames')?.length || 0 > 0
  ).property('contentFilesCount')

  humanContentSize: DS.attr('string')

  contentFilesCount: (->
    count = @get('contentFilenames')?.length || 0

    if 0 == count or count > 1
      "#{count} files"
    else
      "1 file"
  ).property('contentFilenames')

  progressStyle: (->
    "width: #{@get('progress')}%"
  ).property('progress')

  transferURL: (-> "/torrents/#{@get('id')}/transfer" ).property('id')

Cataract.Torrent.reopenClass
  url: 'torrent'
  refreshFromHashes: (hash) ->
    for attr in hash
      record = Cataract.store.find(Cataract.Torrent, attr.id)
      record.setProperties attr if record?
    true

  refreshProgress: ->
    running = Cataract.store.filter Cataract.Torrent, (torrent) -> torrent.get('isRunning')
    $.getJSON "/progress?running=#{running.mapProperty('id').join(',')}", (data, textStatus, xhr) ->
      Cataract.Torrent.refreshFromHashes data.torrents
      true
