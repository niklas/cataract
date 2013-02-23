Cataract.DetectedDirectory = DS.Model.extend
  name: DS.attr('string')
  parent: DS.belongsTo('Cataract.Directory')
  createDirectory: ->
    directory = Cataract.Directory.createRecord
      name: @get('name')
      parent: @get('parent')
    directory.one 'didCreate', => @deleteRecord()

    directory
