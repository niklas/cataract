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
    delete: (router, event) ->
      torrent = event.view.get 'context'
      console?.debug "deleting", torrent
      Bootstrap.ModalPane.popup
        heading: "Delete Torrent"
        torrent: torrent
        bodyViewClass: Cataract.TorrentConfirmDeletionView
        primary: "Delete"
        secondary: "Keep"
        showBackdrop: true
        deletePayload: true
        callback: (opts) ->
          if opts.primary
            torrent.store.createRecord Cataract.Deletion, id: torrent.get('id'), deleteContent: @get('deletePayload')
            torrent.store.commit()
          true


