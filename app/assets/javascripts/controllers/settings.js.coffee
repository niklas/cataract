Cataract.SettingsController = Ember.ObjectController.extend
  content: null
  needs: ['directories']

  save: (x,y) ->
    @get('content.transaction').commit()
    true
