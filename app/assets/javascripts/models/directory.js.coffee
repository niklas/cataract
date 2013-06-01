Cataract.Directory = Emu.Model.extend
  name: Emu.field('string')
  fullPath: Emu.field('string')
  subscribed: Emu.field('boolean')
  filter: Emu.field('string')
  torrents: Emu.field('Cataract.Torrent', collection: true)
  diskId: Emu.field('number')
  disk: Emu.belongsTo('Cataract.Disk', key: 'diskId')
  exists: Emu.field('boolean')
  parentId: Emu.field('number')
  parent: Ember.computed ->
    if pid = @get('parentId')
      Cataract.Directory.find(pid)
    else
      null
  .property('parentId')
  children: Ember.computed ->
    Cataract.Directory.find().filterProperty 'parentId', @get('id')
  .property() # TODO what to depend on here?
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
