attr = DS.attr

Cataract.BaseDirectory = DS.Model.extend
  name: attr('string')
  relativePath: attr('string')
  disk: DS.belongsTo('disk', async: false)
  parentDirectory: DS.belongsTo('directory', async: false)
  nameWithDisk: Ember.computed 'name', 'disk.name', ->
    "#{@get('name')} (#{@get('disk.name')})"

  pathWithDisk: Ember.computed 'disk.name', 'relativePath', ->
    [@get('disk.name'), @get('relativePath')].join(' | ')

  fullPath: Ember.computed 'disk.path', 'relativePath', ->
    [@get('disk.path'), @get('relativePath')].join('/')
