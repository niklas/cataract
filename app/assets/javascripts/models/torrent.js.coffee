Cataract.Torrent = DS.Model.extend
  title: DS.attr 'string'
  percent: DS.attr 'number'
  info_hash: DS.attr 'string'
  status: DS.attr 'string'
  up_rate: DS.attr 'string'
  down_rate: DS.attr 'string'
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

  percentStyle: (->
    "width: #{@get('percent')}%"
  ).property('percent')

Cataract.Torrent.reopenClass
  url: 'torrent'
  refreshProgress: ->
    running = Cataract.store.filter Cataract.Torrent, (torrent) -> torrent.get('isRunning')
    ids = running.mapProperty 'id'
    $.getJSON "/progress?running=#{ids.join(',')}", (data, textStatus, xhr) ->
      for attr in data.torrents
        torrent = Cataract.store.find(Cataract.Torrent, attr.id)
        torrent.setProperties attr if torrent?
      true
