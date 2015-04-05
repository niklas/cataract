Cataract.RunningRoute = Ember.Route.extend
  model: -> @get 'torrents'

  setupController: (c,m)->
    @_super(c,m)

    @controllerFor('application').set 'mode', 'running'
    m.gotoFirstPage()
    m.didRequestRange()
