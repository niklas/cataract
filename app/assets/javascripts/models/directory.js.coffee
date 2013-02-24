Cataract.Directory = DS.Model.extend
  name: DS.attr('string')
  fullPath: DS.attr('string')
  subscribed: DS.attr('boolean')
  filter: DS.attr('string')
  torrents: DS.hasMany('Cataract.Torrent')
  disk: DS.belongsTo('Cataract.Disk', key: 'disk_id')
  exists: DS.attr('boolean')
  cssClass: 'directory'
  parentId: DS.attr 'number'
  parent: DS.belongsTo('Cataract.Directory', key: 'parent_id')
  children: DS.hasMany('Cataract.Directory')
  active: (-> this == Cataract.get('currentDirectory') ).property('Cataract.currentDirectory')
  showSubDirs: DS.attr 'boolean'
  hasSubDirs:(->
    @get('showSubDirs') and @get('children.length') > 0
  ).property('children', 'showSubDirs')

  detectedChildren: Ember.computed ->
    Cataract.DetectedDirectory.find( directory_id: @get('id') )
  .property('children.@each')
  hasDetectedSubDirs: Ember.computed ->
    @get('showSubDirs') and @get('detectedChildren.length') > 0
  .property('showSubDirs', 'detectedChildren.@each', 'children.@each')

  subscribedObserver: (->
    if @get 'subscribed'
      unless @get('filter.length') > 0
        @set 'filter', @get('name')
    ).observes('subscribed')

Cataract.Directory.reopenClass
  url: 'directory'
