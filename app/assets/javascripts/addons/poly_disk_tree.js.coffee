slash = /\//


treeProperty = (dependentKey, property) ->

  klass = Cataract.PolyDiskDirectory
  backProperty = 'poly'

  insert = (list, here, dir) ->
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
      list.pushObject(child) unless list.indexOf(child) >= 0
      insert list, child, dir

  options =
    initialValue: null # shared between instances, will be discarded on first add

    addedItem: (_tree, item, changeMeta, instanceMeta)->
      tree = instanceMeta.tree ||= Ember.Object.create
        root: klass.create()
        all: Ember.A()
      insert tree.get('all'), tree.get('root'), item
      tree

    removedItem: (_tree, item, changeMeta, instanceMeta)->
      # TODO
      instanceMeta.tree

  Ember.reduceComputed dependentKey, "#{dependentKey}.@each.#{property}", options




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
    @get('polies')?.findBy 'relativePath', path
