Cataract.Payload = Emu.Model.extend
  directory: Emu.field('Cataract.Directory')
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
