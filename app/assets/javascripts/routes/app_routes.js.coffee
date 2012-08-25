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
        console.debug "listing", params.status
        # router.get('torrentsController').set('status', params.status)


