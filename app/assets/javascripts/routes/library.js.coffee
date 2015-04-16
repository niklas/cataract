Cataract.LibraryRoute = Ember.Route.extend
  model: -> @get 'torrents'

  setupController: (c,m)->
    @_super(c,m)

    @controllerFor('application').set 'mode', 'library'
    m.gotoFirstPage()
    m.didRequestRange()
