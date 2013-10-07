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
        disk.get('directories').pushObject(directory)
        disk.notifyPropertyChange('detectedDirectories')
        disk.get('detectedDirectories')?.deleteRecord(this)
