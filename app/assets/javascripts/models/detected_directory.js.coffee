Cataract.DetectedDirectory = Cataract.BaseDirectory.extend
  createDirectory: ->
    parentDirectory = @get('parentDirectory')
    disk   = @get('disk')
    directory = @get('store').createRecord 'directory',
      name: @get('name')
      disk: disk
      parentId: @get('parentId')

    directory.save().then =>
      if disk?
        disk.notifyPropertyChange('detectedDirectories')
        disk.get('detectedDirectories')?.deleteRecord(this)
        disk.get('directories').pushObject(directory)
      if parentDirectory?
        parentDirectory.then =>
          parentDirectory.notifyPropertyChange('children')
          parentDirectory.get('detectedChildren')?.deleteRecord(this)
