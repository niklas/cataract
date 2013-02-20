Cataract.Router.map ->
  @resource 'filter', path: 'filter/:mode', ->
    @resource 'directory', path: 'directory/:directory_id'
  @resource 'torrent', path: 'torrent/:torrent_id'
  @resource 'directory', path: 'directory/:directory_id', ->
    @route 'edit', path: 'edit'
  @resource 'disk', path: 'disk/:disk_id'
  @route 'add_torrent', path: 'add'

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
    @controllerFor('application').set('currentController', torrents)

Cataract.FilterRoute = Ember.Route.extend
 # TODO reset event
  activate: ->
    Cataract.set 'currentDirectory', null
    Cataract.set 'currentDisk', null

  model: (params) -> params.mode
  setupController: (controller, model) ->
    torrents = @controllerFor('torrents')
    torrents.set('mode', model)
    @controllerFor('application').set('currentController', torrents)

Cataract.DirectoryRoute = Ember.Route.extend
  setupController: (controller, model) ->
    @_super(controller, model)
    Cataract.set 'currentDirectory', model

Cataract.DiskRoute = Ember.Route.extend
  setupController: (controller, model) ->
    @_super(controller, model)
    Cataract.set 'currentDisk', model

Cataract.AddTorrentRoute = Ember.Route.extend
  model: ->
    Ember.Object.create()
  setupController: (controller, torrent) ->
    # TODO transition route back
    Cataract.AddTorrentModal.popup
      torrent: torrent
      directories: Cataract.Directory.find()
      disks: Cataract.Disk.find()

Cataract.DirectoryEditRoute = Ember.Route.extend
  model: (params) ->
    @modelFor 'directory'
  setupController: (controller, model) ->
    # TODO transition route back
    Cataract.EditDirectoryModal.popup
      directory: model
      back: ['directory', model]

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

    setCurrentDisk: (router, event) ->
      Cataract.set 'currentDisk', event.context


