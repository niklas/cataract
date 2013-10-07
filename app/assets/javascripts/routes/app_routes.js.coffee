Cataract.Router.map ->
  @resource 'filter', path: 'filter/:status'
  @resource 'torrents', queryParams: ['status', 'age', 'directories'], ->
    @resource 'torrent', path: '/torrent/:torrent_id'
    @resource 'directory', path: '/directory/:directory_id', ->
      @route 'edit', path: '/edit'
    @route 'add', path: '/add'
  @resource 'disk', path: 'disk/:disk_id'
  @route 'new_directory', path: 'directory/new'
  @route 'settings'

Cataract.ApplicationRoute = Ember.Route.extend
  beforeModel: ->
    # FIXME is this really needed with all the promises and needs?
    store = @get('store')
    @controllerFor('settings').set    'model',  store.find('setting', 'all')
    @controllerFor('transfers').set   'model', store.findAll('transfer')
    @controllerFor('disks').set       'model', store.findAll('disk')
    @controllerFor('moves').set       'model', store.findAll('move')

Cataract.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'torrents', queryParams: { age: 'month', status: 'running' }

Cataract.FilterRoute = Ember.Route.extend
  beforeModel: (transition) ->
    @transitionTo 'torrents', queryParams: { age: 'month', status: transition.params.status }

Cataract.TorrentsRoute = Ember.Route.extend
  beforeModel: (queryParams)->
    if Ember.isNone(queryParams.age)
      throw "need age queryParam"


  model: (params, queryParams, transition) ->
    store = @get('store')
    # warmup store by site-loading
    store.findQuery('torrent', age: queryParams.age)
    # TODO should we filter&paginate here already or on the controller?
    store.filter 'torrent', (torrent)->
      # do not have to requery the server after deletion of torrent
      ! torrent.get('isDeleted')

  setupController: (controller, model, queryParams) ->
    @setupDirectories(controller, queryParams)
    controller.set 'unfilteredContent', model
    controller.set('mode', queryParams.status)
    controller.gotoFirstPage()
    controller.refreshTransfers()
    @controllerFor('application').set('currentController', controller)

  setupDirectories: (controller, queryParams)->
    unless Ember.isNone(list=queryParams.directories)
      ids = (i for i in list.split(','))
      dirs = @controllerFor('directories')
        .get('directories')
        .filter (d)->
          ids.indexOf(d.get('id')) >= 0
      controller.set 'directories', dirs
      if dirs.get('length') == 1
        dir = dirs.get('firstObject')
        @set 'singleDirectory', true
        @controllerFor('directory').set('content', dir)
      else
        @set 'singleDirectory', false

  renderTemplate: ->
    @render 'torrents/tabs',
      outlet: 'pre',
      controller: @controllerFor('torrents')
    @render 'torrents/navigation',
      outlet: 'nav',
      controller: @controllerFor('torrents')
    if @get('singleDirectory')
      @render 'directory',
        controller: @controllerFor('directory')


Cataract.DirectoryRoute = Ember.Route.extend
  model: (params) ->
    @get('store').find 'directory', params.directory_id # FIXME ember should do this
  afterModel: (model)->
    @controllerFor('torrents').set('directory', model)
  controllerName: 'directory'
  renderTemplate: ->
    @render 'directory'
  deactivate: (model)->
    @controllerFor('torrents').set('directory', null)

Cataract.TorrentRoute = Ember.Route.extend
  beforeModel: ->
    @controllerFor('torrents').get('unfilteredContent') # waiting for promise to resolve
  model: (params) ->
    @get('store').find 'torrent', params.torrent_id

Cataract.TorrentsAddRoute = Ember.Route.extend
  model: -> @get('store').createRecord('torrent')
  setupController: (controller, torrent) ->
    controller.set 'content', torrent
    #@_super(controller, torrent)
    router = this
    store = @get('store')
    controller.setDefaultDirectory()

    Cataract.AddTorrentModal.popup
      controller: controller
      torrent: torrent
      ok: (opts)->
        record = @get('torrent')
        record.setProperties
          fetchAutomatically: true
          startAutomatically: true
        record.save()
      cancel: (opts)->
        @get('torrent').deleteRecord()
      backRoute: ['torrent', torrent]

Cataract.NewDirectoryRoute = Ember.Route.extend
  model: ->
    @get('store').createRecord 'directory'
      disk: Cataract.get('currentDisk')
      parentDirectory: @controllerFor('torrents').get('directory')
      virtual: false

  setupController: (controller, model) ->
    # TODO transition route back
    Cataract.NewDirectoryModal.popup
      directory: model
      directories: model.get('disk.directories')
      disks: @get('store').findAll('disk')

  renderTemplate: ->

Cataract.DirectoryEditRoute = Ember.Route.extend
  model: (params) ->
    @modelFor 'directory'
  setupController: (controller, model) ->
    # TODO transition route back
    Cataract.EditDirectoryModal.popup
      controller: controller
      directory: model
      backRoute: ['directory.index', model]

Cataract.SettingsRoute = Ember.Route.extend
  model: ->
    @get('store').find('setting', 'all')
