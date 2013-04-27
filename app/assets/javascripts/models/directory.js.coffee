Cataract.Directory = Emu.Model.extend
  name: Emu.field('string')
  fullPath: Emu.field('string')
  subscribed: Emu.field('boolean')
  filter: Emu.field('string')
  torrents: Emu.field('Cataract.Torrent', collection: true)
  disk: Emu.field('Cataract.Disk', key: 'disk_id')
  exists: Emu.field('boolean')
  parentId: Emu.field 'number'
  parent: Emu.field('Cataract.Directory', key: 'parent_id')
  children: Emu.field('Cataract.Directory', collection: true)
  active: (-> this == Cataract.get('currentDirectory') ).property('Cataract.currentDirectory')
  showSubDirs: Emu.field 'boolean'
  virtual: Emu.field 'boolean'
  hasSubDirs:(->
    @get('showSubDirs') and @get('children.length') > 0
  ).property('children.@each', 'showSubDirs')

  detectedChildren: Ember.computed ->
    Cataract.DetectedDirectory.find( directory_id: @get('id') )
  .property('children.@each.id')
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
