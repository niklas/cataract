Cataract.Directory = Cataract.BaseDirectory.extend
  fullPath: Emu.field('string')
  subscribed: Emu.field('boolean')
  filter: Emu.field('string')
  torrents: Emu.field('Cataract.Torrent', collection: true)
  exists: Emu.field('boolean')
  children: Ember.computed ->
    @get('disk.directories')?.filterProperty('parentId', @get('id'))
  .property('disk.directories.@each')
  active: (-> this == Cataract.get('currentDirectory') ).property('Cataract.currentDirectory')
  showSubDirs: Emu.field 'boolean'
  virtual: Emu.field 'boolean'
  hasSubDirs:(->
    @get('showSubDirs') and @get('children.length') > 0
  ).property('children', 'children.@each', 'showSubDirs')

  detectedChildren: Emu.field('Cataract.DetectedDirectory', collection: true, lazy: true)
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
