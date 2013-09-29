Cataract.BaseDirectory = Emu.Model.extend
  name: Emu.field('string')
  diskId: Emu.field('number')
  disk: Emu.belongsTo('Cataract.Disk', key: 'diskId')
  parentId: Emu.field('number')
  parent: Ember.computed ->
    Cataract.Directory.find( @get('parentId') )
  .property('parentId', 'disk.directories.@each')
  nameWithDisk: Ember.computed ->
    "#{@get('name')} (#{@get('disk.name')})"
  .property('name', 'disk.name')
