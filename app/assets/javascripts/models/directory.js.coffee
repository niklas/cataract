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
  # TODO use observer for this?
  #active: (-> this == Cataract.get('currentDirectory') ).property('Cataract.currentDirectory')
  showSubDirs: attr 'boolean'
  virtual: attr 'boolean'

  detectedChildren: Ember.computed ->
    @get('store').findQuery('detectedDirectory', directory_id: @get('id'))
  .property()

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
