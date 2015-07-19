attr = DS.attr

Cataract.Payload = DS.Model.extend
  directory: DS.belongsTo('directory', async: false)
  size: attr 'number'
  filenames: attr 'staticArray'
  torrent: DS.belongsTo('torrent', async: false)

  hasContent: (->
    @get('filenames')?.length || 0 > 0
  ).property('filesCount')

  filesCount: (->
    count = @get('filenames')?.length || 0

    if 0 == count or count > 1
      "#{count} files"
    else
      "1 file"
  ).property('filenames')
