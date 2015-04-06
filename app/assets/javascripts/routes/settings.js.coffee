Cataract.SettingsRoute = Ember.Route.extend
  model: ->
    @get('store').find('setting', 'all')
