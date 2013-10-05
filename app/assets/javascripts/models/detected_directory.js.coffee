Cataract.DetectedDirectory = Cataract.BaseDirectory.extend
  createDirectory: ->
    parentDirectory = @get('parentDirectory')
    disk   = @get('disk')
    directory = Cataract.Directory.createRecord
      name: @get('name')
      disk: disk
      parentDirectory: parentDirectory
    directory.one 'didFinishSaving', =>
      if disk?
        disk.notifyPropertyChange('detectedDirectories')
        disk.get('detectedDirectories')?.deleteRecord(this)
        disk.get('directories').pushObject(directory)
      if parentDirectory?
        parentDirectory.notifyPropertyChange('children')
        parentDirectory.get('detectedChildren')?.deleteRecord(this)
    directory

Cataract.DetectedDirectory.reopenClass
  resourceName: 'detected_directories'
