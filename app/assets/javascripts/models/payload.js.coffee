Cataract.Payload = Emu.Model.extend
  directoryId: Emu.field 'number'
  directory: Emu.belongsTo('Cataract.Directory', key: 'directoryId')
  size: Emu.field 'number'
  filenames: Emu.field 'staticArray'
  humanSize: Emu.field('string')

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
