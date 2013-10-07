attr = DS.attr

Cataract.Disk = DS.Model.extend
  name: attr('string')
  isMounted: attr('boolean')
  active: (-> this == Cataract.get('currentDisk') ).property('Cataract.currentDisk')
  # FIXME not loaded
  directories: DS.hasMany('directory')
  hasDirectories: Ember.computed ->
    @get('directories.length') > 0
  .property('directories.@each')

  detectedDirectories: Ember.computed ->
    @get('store').findQuery('detectedDirectory', disk_id: @get('id'))
  .property('directories.@each')

  hasDetectedDirs: Ember.computed ->
    @get('detectedDirectories.length') > 0
  .property('detectedDirectories.@each', 'directories.@each.id')
