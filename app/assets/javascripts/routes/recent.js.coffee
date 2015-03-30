Cataract.RecentRoute = Ember.Route.extend
  model: -> @get 'torrents'

  setupController: (c,m)->
    @_super(c,m)

    @controllerFor('application').set 'mode', 'recent'
