Cataract.Payload = DS.Model.extend
  directory: DS.belongsTo('Cataract.Directory')
  size: DS.attr 'number'
  filenames: DS.attr 'staticArray'
  humanSize: DS.attr('string')

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
