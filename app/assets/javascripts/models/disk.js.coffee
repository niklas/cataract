Cataract.Disk = DS.Model.extend
  name: DS.attr('string')
  isMounted: DS.attr('boolean')
  cssClass: 'disk'
  active: (-> this == Cataract.get('currentDisk') ).property('Cataract.currentDisk')
  directories: DS.hasMany('Cataract.Directory')
  hasDirectories: Ember.computed ->
    @get('directories.length') > 0
  .property('directories.@each')
