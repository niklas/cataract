Cataract.SettingsController = Ember.ObjectController.extend
  content: null
  needs: ['directories']

  save: (x,y) ->
    @get('content').save()
    true
