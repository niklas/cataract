Cataract.SettingsController = Ember.ObjectController.extend
  needs: ['directories']

  directoriesBinding: 'controllers.directories.poly.directories'

  save: (x,y) ->
    @get('content').save()
    true
