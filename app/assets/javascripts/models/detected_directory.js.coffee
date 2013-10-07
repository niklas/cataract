Cataract.DetectedDirectory = Cataract.BaseDirectory.extend
  createDirectory: ->
    parentDirectory = @get('parentDirectory')
    disk   = @get('disk')
    directory = @get('store').createRecord 'directory',
      name: @get('name')
      disk: disk
      parentId: @get('parentId')

    directory.save().then =>
      @unloadRecord()
      if disk?
        disk.notifyPropertyChange('detectedDirectories')
        # FIXME should not be neccessary with the store, when assoc would work
        disk.get('directories').pushObject(directory)
      if parentDirectory?
        parentDirectory.then (p) =>
          p.notifyPropertyChange('detectedChildren')
