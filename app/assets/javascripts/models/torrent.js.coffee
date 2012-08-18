Cataract.Torrent = DS.Model.extend
  title: DS.attr 'string'
  percent: DS.attr 'number'
  info_hash: DS.attr 'string'
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
