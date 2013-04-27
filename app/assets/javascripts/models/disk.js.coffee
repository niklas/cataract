Cataract.Disk = Emu.Model.extend
  name: Emu.field('string')
  isMounted: Emu.field('boolean')
  active: (-> this == Cataract.get('currentDisk') ).property('Cataract.currentDisk')
  directories: Emu.field('Cataract.Directory', collection: true)
  hasDirectories: Ember.computed ->
    @get('directories.length') > 0
  .property('directories.@each')

  detectedDirectories: Ember.computed ->
    Cataract.DetectedDirectory.find( disk_id: @get('id') )
  .property('directories.@each.id')
  hasDetectedDirs: Ember.computed ->
    @get('detectedDirectories.length') > 0
  .property('detectedDirectories.@each', 'directories.@each.id')
