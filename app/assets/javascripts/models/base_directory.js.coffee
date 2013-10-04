attr = DS.attr

Cataract.BaseDirectory = DS.Model.extend
  name: attr('string')
  diskId: attr('number')
  disk: DS.belongsTo('disk')
  parentId: attr('number')
  # 'parent' is special in Emu #doh
  parentDirectory: Ember.computed ->
    Cataract.Directory.find( @get('parentId') )
  .property('parentId', 'disk.directories.@each')
  nameWithDisk: Ember.computed ->
    "#{@get('name')} (#{@get('disk.name')})"
  .property('name', 'disk.name')
