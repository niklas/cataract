Cataract.DetectedDirectory = DS.Model.extend
  name: DS.attr('string')
  parent: DS.belongsTo('Cataract.Directory')
  disk: DS.belongsTo('Cataract.Disk')
  createDirectory: ->
    parent = @get('parent')
    disk   = @get('disk')
    directory = Cataract.Directory.createRecord
      name: @get('name')
      parent: parent
      disk: disk
    directory.one 'didCreate', ->
      # FIXME Ember/me is too stupid to get the change
      # caused re-fetch of #detectedChildren
      parent.get('children').addObject(directory) if parent?
      disk.get('directories').addObject(directory) if disk?
    directory
