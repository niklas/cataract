Cataract.Payload = DS.Model.extend
  directory: DS.belongsTo('Cataract.Directory')
  size: DS.attr 'number'
  filenames: DS.attr 'staticArray'
  humanContentSize: DS.attr('string')

  hasContent: (->
    @get('contentFilenames')?.length || 0 > 0
  ).property('contentFilesCount')

  contentFilesCount: (->
    count = @get('contentFilenames')?.length || 0

    if 0 == count or count > 1
      "#{count} files"
    else
      "1 file"
  ).property('contentFilenames')
