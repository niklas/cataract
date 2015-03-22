attr = DS.attr

Cataract.BaseDirectory = DS.Model.extend
  name: attr('string')
  relativePath: attr('string')
  disk: DS.belongsTo('disk')
  parentDirectory: DS.belongsTo('directory')
  nameWithDisk:
    Ember.computed ->
      "#{@get('name')} (#{@get('disk.name')})"
    .property('name', 'disk.name')
