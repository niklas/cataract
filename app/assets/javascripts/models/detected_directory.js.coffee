Cataract.DetectedDirectory = Cataract.BaseDirectory.extend
  createDirectory: ->
    parentDirectory = @get('parentDirectory')
    disk   = @get('disk')
    directory = @get('store').createRecord 'directory',
      name: @get('name')
      disk: disk
      parentDirectory: @get('parentDirectory')
      relativePath: @get('relativePath')

    directory.save().then =>
      @unloadRecord()
