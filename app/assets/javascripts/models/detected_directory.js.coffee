Cataract.DetectedDirectory = Cataract.BaseDirectory.extend
  createDirectory: ->
    parent = @get('parent')
    disk   = @get('disk')
    directory = Cataract.Directory.createRecord
      name: @get('name')
      diskId: disk?.get('id')
      parentId: parent?.get('id')
    directory.one 'didFinishSaving', =>
      if disk?
        disk.notifyPropertyChange('detectedDirectories')
        disk.get('detectedDirectories')?.deleteRecord(this)
        disk.get('directories').pushObject(directory)
      if parent?
        parent.notifyPropertyChange('children')
        parent.get('detectedChildren')?.deleteRecord(this)
    directory

Cataract.DetectedDirectory.reopenClass
  resourceName: 'detected_directories'
