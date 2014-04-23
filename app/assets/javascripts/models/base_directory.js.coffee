attr = DS.attr

Cataract.BaseDirectory = DS.Model.extend
  name: attr('string')
  relativePath: attr('string')
  disk: DS.belongsTo('disk')
  parentId: attr('number')
  # 'parent' is special in Emu #doh
  parentDirectory:
    Ember.computed ->
      @get('store').find('directory', @get('parentId') ) if @get('parentId')?
    .property('parentId', 'disk.directories.@each')
  nameWithDisk:
    Ember.computed ->
      "#{@get('name')} (#{@get('disk.name')})"
    .property('name', 'disk.name')
