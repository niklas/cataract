Cataract.FeedsRoute = Ember.Route.extend
  model: ->
    @get('store').findAll 'feed'

