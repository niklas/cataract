Cataract.Router.map ->
  @route 'recent'
  @route 'running'
  @resource 'directories'
  @route 'add'

Cataract.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'recent'
  setupController: (controller) ->
    console.debug("index.setup")


Cataract.TorrentsRoute = Ember.Route.extend
  model: -> Cataract.Torrent.find()

  filterFunction: -> true

  setupController: (controller, model) ->
    torrents = @controllerFor('torrents')
    torrents.set('mode', @mode())
    torrents.set('pureContent', model)
    @controllerFor('application').setSiteTitleByController(torrents)

  renderTemplate: ->
    @render 'torrents', controller: 'torrents'
  mode: -> 'all'

Cataract.RecentRoute = Cataract.TorrentsRoute.extend
  mode: -> 'recent'
Cataract.RunningRoute = Cataract.TorrentsRoute.extend
  model: -> Cataract.Torrent.find(status: 'running')
  mode: -> 'running'

Cataract.Routerle = Ember.Object.extend
  enableLogging:  true
  location: 'hash'
  # as routes are not processed along its paths, we have to connect the outlet automagically
  listTorrents: ->
    torrents = @get('torrentsController')
    unless torrents.get('listOutlet')?
      @get('applicationController').connectOutlet 'torrents'
    torrents

  #setCurrentDirectory: Ember.Route.transitionTo('directories.show')
  #goToDirectory: Ember.Route.transitionTo('directories.show')
  #listRecent: Ember.Router.transitionTo('recent')
  #listRunning: Ember.Router.transitionTo('running')
  root: Ember.Route.extend
    recent: Ember.Route.extend
      route: '/torrents/recent'
      connectOutlets: (router, params) ->
        torrents = router.listTorrents()
        torrents.set('mode', 'recent')

    running: Ember.Route.extend
      route: '/torrents/running'
      connectOutlets: (router, params) ->
        torrents = router.listTorrents()
        torrents.set('mode', 'running')

    directories: Ember.Route.extend
      route: '/directories'
      connectOutlets: (router) ->
        router.listTorrents()
      #editDirectory: Ember.Route.transitionTo('directories.edit')
      show: Ember.Route.extend
        route: '/show/:directory_id'
        connectOutlets: (router, directory) ->
          Cataract.set 'currentDirectory', directory
          router.get('applicationController').connectOutlet 'pre', 'directory', directory
      edit: Ember.Route.extend
        route: '/edit/:directory_id'
        connectOutlets: (router, directory) ->
          transaction = Cataract.store.transaction()
          transaction.add directory
          @set 'transaction', transaction
          router.get('applicationController').connectOutlet 'pre', 'editDirectory', directory
        save: (router) ->
          @get('transaction').commit()
          directory = Cataract.get('currentDirectory')
          router.transitionTo 'directories.show', directory

        cancel: (router) ->
          @get('transaction').rollback()
          directory = Cataract.get('currentDirectory')
          router.transitionTo 'directories.show', directory

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
      proto = {
        id: torrent.get('id')
        targetDisk: directory.get('disk.id')
        targetDirectory: directory.get('id')
      }
      Bootstrap.ModalPane.popup
        heading: "Move payload"
        torrent: torrent
        move: proto
        bodyViewClass: Cataract.MoveTorrentView
        primary: "Move"
        secondary: "Cancel"
        showBackdrop: true
        callback: (opts) ->
          if opts.primary
            move = torrent.store.createRecord Cataract.Move, proto
            move.store.commit()
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
              try
                payload.deleteRecord()
              catch error
                console?.debug "error while clearing payload: #{error}, trying to continue"
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


