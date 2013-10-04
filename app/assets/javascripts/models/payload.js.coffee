attr = DS.attr

Cataract.Payload = DS.Model.extend
  directoryId: attr 'number'
  directory: DS.belongsTo('directory', key: 'directoryId')
  size: attr 'number'
  filenames: attr 'staticArray'
  humanSize: attr 'string'

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
