Cataract.Router = Ember.Router.extend
  location: 'hash'
  root: Ember.Route.extend
    index: Ember.Route.extend
      route: '/'
      connectOutlets: (router) ->
        router.transitionTo 'list', status: 'recent'
    list: Ember.Route.extend
      route: '/torrents/:status'
      connectOutlets: (router, params) ->
        torrents = router.get('torrentsController')
        unless torrents.get('listOutlet')?
          router.get('applicationController').connectOutlet 'torrents'
        torrents.set('status', params.status)


