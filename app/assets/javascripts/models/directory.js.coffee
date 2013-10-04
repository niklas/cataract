attr = DS.attr

Cataract.Directory = Cataract.BaseDirectory.extend
  fullPath: Ember.computed ->
    [@get('disk.path'), @get('relativePath')].join('/')
  .property('disk.path', 'relativePath')
  relativePath: attr('string')
  subscribed: attr('boolean')
  filter: attr('string')
  torrents: DS.hasMany('torrent')
  exists: attr('boolean')
  children: Ember.computed ->
    @get('disk.directories')?.filterProperty('parentId', @get('id'))
  .property('disk.directories.@each.parentId')
  active: (-> this == Cataract.get('currentDirectory') ).property('Cataract.currentDirectory')
  showSubDirs: attr 'boolean'
  virtual: attr 'boolean'
  hasSubDirs:(->
    @get('showSubDirs') and @get('children.length') > 0
  ).property('children', 'children.@each', 'showSubDirs')

  detectedChildren: DS.hasMany('detected-directory')
  hasDetectedSubDirs: Ember.computed ->
    @get('showSubDirs') and @get('detectedChildren.length') > 0
  .property('showSubDirs', 'detectedChildren.@each', 'children.@each.id')

  subscribedObserver: (->
    if @get 'subscribed'
      unless @get('filter.length') > 0
        @set 'filter', @get('name')
    ).observes('subscribed')

Cataract.Directory.reopenClass
  url: 'directory'
  resourceName: 'directories'
