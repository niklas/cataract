Cataract.DetectedDirectory = Emu.Model.extend
  name: Emu.field('string')
  parent: Emu.field('Cataract.Directory')
  diskId: Emu.field('number')
  disk: Emu.belongsTo('Cataract.Disk', key: 'diskId')
  createDirectory: ->
    parent = @get('parent')
    disk   = @get('disk')
    directory = disk.get('directories').createRecord name: @get('name')
    directory.one 'didFinishSaving', =>
      disk.get('detectedDirectories').deleteRecord(this)
      #parent.get('children').addObject(directory) if parent?
      #disk.get('directories').addObject(directory) if disk?
    directory

Cataract.DetectedDirectory.reopenClass
  resourceName: 'detected_directories'
