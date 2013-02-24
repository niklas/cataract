Cataract.DetectedDirectory = DS.Model.extend
  name: DS.attr('string')
  parent: DS.belongsTo('Cataract.Directory')
  createDirectory: ->
    parent = @get('parent')
    directory = Cataract.Directory.createRecord
      name: @get('name')
      parent: parent
    directory.one 'didCreate', ->
      # FIXME Ember/me is too stupid to get the change
      # caused re-fetch of #detectedChildren
      parent.get('children').addObject(directory)
    directory
