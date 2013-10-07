Cataract.DirectoryController = Ember.ObjectController.extend
  needs: ['directories']

  # associations do not load nicely
  # TODO move into models
  children: Ember.computed ->
    @get('controllers.directories.directories').filterProperty('parentId', parseInt(@get('content.id')))
  .property('controllers.directories.directories.@each.parentId', 'content.id')
  hasSubDirs:(->
    @get('showSubDirs') and @get('children.length') > 0
  ).property('children.length', 'showSubDirs')
