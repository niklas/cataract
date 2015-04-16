slash = /\//

get = Ember.get
reduceComputed = Ember.reduceComputed

treeProperty = (dependentKey, property) ->

  klass = Cataract.PolyDiskDirectory
  backProperty = 'poly'

  insert = (tree, here, dir) ->
    herePath = here.get(property)
    dirPath  = dir.get(property)
    if herePath is dirPath # dir is an alternative of here
      here.get('alternatives').addObject dir
      dir.set(backProperty, here)
    else if dirPath.indexOf(herePath) is 0 # dir is sub of here
      if herePath.length is 0 # we are at root, just use first component
        nameOnDisk = dirPath.split(slash)[0]
      else
        cut = dirPath.slice( herePath.length + 1 ) # dir path from here (+ slash)
        nameOnDisk = cut.split(slash)[0]

      child = here.getOrBuildChildByNameOnDisk(nameOnDisk)
      list = tree.get('all')
      list.pushObject(child) unless list.indexOf(child) >= 0
      insert tree, child, dir

  options =
    initialValue: null
    initialize: (_tree, changeMeta, instanceMeta)->
      tree = Ember.Object.create
        root: klass.create()
        all:  Ember.A()

    addedItem: (tree, item, changeMeta, instanceMeta)->
      insert tree, tree.get('root'), item
      tree

    removedItem: (tree, item, changeMeta, instanceMeta)->
      # TODO
      tree

  reduceComputed "#{dependentKey}.@each.#{property}", options




Cataract.PolyDiskTreeMixin = Ember.Mixin.create
  # Entry point, all directories, unstructed
  #
  # accepts a collection, for example a findAll
  # sets observers on it
  directories: Ember.A()
  tree: treeProperty 'directories', 'relativePath'
  # exit point, responds to #children and each to #alternatives
  rootBinding: 'tree.root'
  poliesBinding: 'tree.all'

  findPolyByPath: (path)->
    @get('polies').findBy 'relativePath', path
