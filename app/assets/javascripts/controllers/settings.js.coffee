Cataract.SettingsController = Ember.ObjectController.extend
  needs: ['directories']

  save: (x,y) ->
    @get('content').save()
    true
