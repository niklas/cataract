Cataract.Disk = DS.Model.extend
  name: DS.attr('string')
  isMounted: DS.attr('boolean')
  active: (-> this == Cataract.get('currentDisk') ).property('Cataract.currentDisk')
  directories: DS.hasMany('Cataract.Directory')
  hasDirectories: Ember.computed ->
    @get('directories.length') > 0
  .property('directories.@each')

  detectedDirectories: Ember.computed ->
    Cataract.DetectedDirectory.find( disk_id: @get('id') )
  .property('directories.@each.id')
  hasDetectedDirs: Ember.computed ->
    @get('detectedDirectories.length') > 0
  .property('detectedDirectories.@each', 'directories.@each.id')
