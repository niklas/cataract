Cataract.Router = Ember.Router.extend
  enableLogging:  true
  location: 'hash'
  setCurrentDirectory: Ember.Route.transitionTo('directories')
  goToDirectory: Ember.Route.transitionTo('directories')
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

    directories: Ember.Route.extend
      route: '/directories/:directory_id'
      editDirectory: Ember.Route.transitionTo('directories.edit')
      connectOutlets: (router, directory) ->
        Cataract.set 'currentDirectory', directory
        router.get('applicationController').connectOutlet 'pre', 'directory', directory
      edit: Ember.Route.extend
        route: '/edit'
        connectOutlets: (router, directory) ->
          directory = Cataract.get 'currentDirectory'
          transaction = Cataract.store.transaction()
          transaction.add directory
          @set 'transaction', transaction
          router.get('applicationController').connectOutlet 'pre', 'editDirectory', directory
        save: (router) ->
          @get('transaction').commit()
          directory = Cataract.get('currentDirectory')
          router.transitionTo 'directories', directory

        cancel: (router) ->
          @get('transaction').rollback()
          directory = Cataract.get('currentDirectory')
          router.transitionTo 'directories', directory

    add: (router, event) ->
      torrent = Cataract.Torrent.createRecord
        fetchAutomatically: true
        startAutomatically: true
      Bootstrap.ModalPane.popup
        heading: "Add Torrent"
        torrent: torrent
        bodyViewClass: Cataract.AddTorrentView
        primary: "Add"
        secondary: "Cancel"
        showBackdrop: true
        callback: (opts) ->
          if opts.primary
            torrent.store.commit()
          else
            torrent.deleteRecord()
          true

    move: (router, event) ->
      torrent = event.view.get 'context'
      directory = torrent.get('payload.directory') || torrent.get('contentDirectory')
      move = torrent.store.createRecord Cataract.Move,
        id: torrent.get('id')
        targetDisk: directory.get('disk')
        targetDirectory: directory
      Bootstrap.ModalPane.popup
        heading: "Move payload"
        torrent: torrent
        move: move
        bodyViewClass: Cataract.MoveTorrentView
        primary: "Move"
        secondary: "Cancel"
        showBackdrop: true
        callback: (opts) ->
          if opts.primary
            move.store.commit()
          else
            move.deleteRecord()
          true

    clear: (router, event) ->
      torrent = event.view.get 'context'
      Bootstrap.ModalPane.popup
        heading: "Clear Torrent"
        torrent: torrent
        bodyViewClass: Cataract.TorrentConfirmClearanceView
        primaryBinding: 'confirmButtonLabel'
        confirmButtonLabel: (->
         "Clear #{@get('torrent.payload.humanSize')}"
        ).property('torrent.payload.humanSize')
        secondary: "still need it"
        showBackdrop: true
        callback: (opts) ->
          if opts.primary
            if payload = torrent.get('payload')
              payload.deleteRecord()
              payload.store.commit()
          true

    delete: (router, event) ->
      torrent = event.view.get 'context'
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
            torrent.store.createRecord Cataract.Deletion, id: torrent.get('id'), deletePayload: @get('deletePayload')
            torrent.get('stateManager').goToState('deleted.saved')
            torrent.store.commit()
          true

    setCurrentDisk: (router, event) ->
      Cataract.set 'currentDisk', event.context


