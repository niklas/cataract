Cataract.DetectedDirectory = Emu.Model.extend
  name: Emu.field('string')
  parent: Emu.field('Cataract.Directory')
  disk: Emu.field('Cataract.Disk')
  createDirectory: ->
    parent = @get('parent')
    disk   = @get('disk')
    transaction = Cataract.store.transaction()
    directory = transaction.createRecord Cataract.Directory,
      name: @get('name')
      parent: parent
      disk: disk
    directory.one 'didCreate', ->
      # FIXME Ember/me is too stupid to get the change
      # caused re-fetch of #detectedChildren
      parent.get('children').addObject(directory) if parent?
      disk.get('directories').addObject(directory) if disk?
    directory

Cataract.DetectedDirectory.reopenClass
  resourceName: 'detected_directories'
