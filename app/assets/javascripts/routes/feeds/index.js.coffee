Cataract.FeedsIndexRoute = Ember.Route.extend
  model: ->
    @get('store').findAll 'feed'
