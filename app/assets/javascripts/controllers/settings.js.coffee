Cataract.SettingsController = Ember.ObjectController.extend
  needs: ['directories']

  directoriesBinding: 'controllers.directories.directories'

  save: (x,y) ->
    @get('content').save()
    true
