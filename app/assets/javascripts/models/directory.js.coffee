attr = DS.attr

Cataract.Directory = Cataract.BaseDirectory.extend
  fullPath:
    Ember.computed ->
      [@get('disk.path'), @get('relativePath')].join('/')
    .property('disk.path', 'relativePath')
  subscribed: attr('boolean')
  filter: attr('string')
  torrents: DS.hasMany('torrent')
  exists: attr('boolean')
  # TODO use observer for this?
  #active: (-> this == Cataract.get('currentDirectory') ).property('Cataract.currentDirectory')
  showSubDirs: attr 'boolean'

  children: DS.hasMany 'directory', inverse: 'parentDirectory'
  hasSubDirs: Ember.computed 'children.length', 'showSubDirs',->
    @get('showSubDirs') and @get('children.length') > 0
  virtual: attr 'boolean'

  detectedChildren: Ember.computed ->
    @get('store').findQuery('detectedDirectory', directory_id: @get('id'))

  hasDetectedSubDirs: Ember.computed 'showSubDirs', 'detectedChildren.@each', 'children.@each.id', ->
      @get('showSubDirs') and @get('detectedChildren.length') > 0

  subscribedObserver: (->
    if @get 'subscribed'
      unless @get('filter.length') > 0
        @set 'filter', @get('name')
    ).observes('subscribed')

  ancestorsAndSelf: Ember.computed 'parentDirectory', ->
    if parent = @get('parentDirectory')
      list = parent.get('ancestorsAndSelf')
      list.pushObject this
      list
    else
      [ this ]

  descendantsAndSelf: Ember.computed 'children.@each', ->
    list = [ this ]
    @get('children').mapProperty('descendantsAndSelf').forEach (descs)->
      list.pushObjects(descs)
    list

Cataract.Directory.reopenClass
  url: 'directory'
  resourceName: 'directories'
