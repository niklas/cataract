Cataract.Router.map ->
  @resource 'torrents', ->
    @resource 'filter', path: 'filter/:mode'
    @resource 'torrent', path: ':torrent_id'
  @resource 'directories', ->
    @resource 'directory', path: ':directory_id'
  @resource 'disks', ->
    @resource 'disk', path: ':disk_id'
  @route 'add'

Cataract.ApplicationRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('torrents').set    'model', Cataract.Torrent.find()
    @controllerFor('transfers').set   'model', Cataract.Transfer.find()
    @controllerFor('directories').set 'model', Cataract.Directory.find()
    @controllerFor('disks').set       'model', Cataract.Disk.find()
    @controllerFor('moves').set       'model', Cataract.Move.find()

Cataract.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'filter', 'recent'

Cataract.TorrentsRoute = Ember.Route.extend
  model: -> Cataract.Torrent.find()
  setupController: (torrents, model) ->
    application = @controllerFor('application')
    torrents.addObserver 'siteTitle', torrents, ->
      application.setSiteTitleByController(torrents)
  events:
    deletePayload: (torrent) ->
      Cataract.ClearPayloadModal.popup torrent: torrent

    move: (torrent) ->
      directory = torrent.get('payload.directory') || torrent.get('contentDirectory')
      Cataract.MovePayloadModal.popup
        torrent: torrent
        directories: @controllerFor('directories').get('content')
        disks: @controllerFor('disks').get('content')
        move: Ember.Object.create
          targetDisk: directory.get('disk.id')
          targetDirectory: directory.get('id')



Cataract.FilterRoute = Ember.Route.extend
  model: (params) -> params.mode
  setupController: (controller, model) ->
    torrents = @controllerFor('torrents')
    torrents.set('mode', model)

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


