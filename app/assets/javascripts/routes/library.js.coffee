Cataract.LibraryRoute = Ember.Route.extend
  model: -> @get 'torrents'

  setupController: (c,m)->
    @_super(c,m)

    m.gotoFirstPage()
    m.didRequestRange()
