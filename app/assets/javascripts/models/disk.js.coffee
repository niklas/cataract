attr = DS.attr

Cataract.Disk = DS.Model.extend
  name: attr('string')
  isMounted: attr('boolean')
  active: (-> this == Cataract.get('currentDisk') ).property('Cataract.currentDisk')
  directories: DS.hasMany('directory')
  hasDirectories: Ember.computed ->
    @get('directories.length') > 0
  .property('directories.@each')

  detectedDirectories: DS.hasMany('detected-directory')
  hasDetectedDirs: Ember.computed ->
    @get('detectedDirectories.length') > 0
  .property('detectedDirectories.@each', 'directories.@each.id')
