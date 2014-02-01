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
  beforeModel: (queryParams, transition)->
    if Ember.isNone(queryParams.age)
      queryParams.age = 'month'
    if Ember.isNone(queryParams.status)
      queryParams.status = 'recent'

    store = @get('store')
    # warmup store only when age has changed
    if queryParams.age != transition.params.queryParams?.age
      store.unloadAll('torrent')
      store.findQuery('torrent', age: queryParams.age)

    @setupDirectories(queryParams) # promise

  model: (params, queryParams, transition) ->
    # TODO should we filter&paginate here already or on the controller?
    @get('store').filter 'torrent', (torrent)->
      # do not have to requery the server after deletion of torrent
      ! torrent.get('isDeleted')

  setupDirectories: (queryParams)->
    unless Ember.isNone(list=queryParams.directories)
      ids = (i for i in list.split(','))
      @controllerFor('directories')
        .get('directories')
        .then (all) =>
          dirs = all.filter (d)->
            ids.indexOf(d.get('id')) >= 0
          @set 'directories', dirs
          if dirs.get('length') == 1
            dir = dirs.get('firstObject')
            @set 'singleDirectory', dir
            @controllerFor('directory').set('model', dir)
          else
            @set 'singleDirectory', false

  setupController: (controller, model, queryParams) ->
    controller.set 'directories', @get('directories')
    controller.set 'unfilteredContent', model
    controller.set('mode', queryParams.status)
    controller.set('age', queryParams.age)
    controller.gotoFirstPage()
    controller.refreshTransfers()
    @controllerFor('application').set('currentController', controller)

  renderTemplate: ->
    @render 'torrents/tabs',
      outlet: 'bar',
      controller: @controllerFor('torrents')
    @render 'torrents/navigation',
      outlet: 'nav',
      controller: @controllerFor('torrents')
    if @get('singleDirectory')
      @controllerFor('application').set 'detailsExtended', true
      @render 'directory',
        controller: @controllerFor('directory')
    else
      @controllerFor('application').set 'detailsExtended', false

Cataract.DetailedRoute = Ember.Route.extend
  setupController: (controller, model)->
    @_super(controller, model)
    @controllerFor('application').set 'detailsExtended', true
  deactivate: ->
    @_super()
    @controllerFor('application').set 'detailsExtended', false


# this is dead, isn't it?
Cataract.DirectoryRoute = Cataract.DetailedRoute.extend
  model: (params) ->
    @get('store').find 'directory', params.directory_id # FIXME ember should do this
  afterModel: (model)->
    @controllerFor('torrents').set('directory', model)
  controllerName: 'directory'
  renderTemplate: ->
    @render 'directory'
  deactivate: (model)->
    @_super()
    @controllerFor('torrents').set('directory', null)

Cataract.TorrentRoute = Cataract.DetailedRoute.extend
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
      disk: @modelFor('disk')
      parentDirectory: @controllerFor('torrents').get('directory')
      virtual: false

  setupController: (controller, model) ->
    # TODO transition route back
    Cataract.NewDirectoryModal.popup
      directory: model
      directories: model.get('disk.directories')
      disks: @get('store').findAll('disk')

  renderTemplate: ->

Cataract.DirectoryEditRoute = Cataract.DetailedRoute.extend
  model: (params) ->
    @modelFor 'directory'
  setupController: (controller, model) ->
    @_super(controller, model)
    # TODO transition route back
    Cataract.EditDirectoryModal.popup
      controller: controller
      directory: model
      done: -> history.back(-1)

Cataract.DiskRoute = Cataract.DetailedRoute.extend()

Cataract.SettingsRoute = Cataract.DetailedRoute.extend
  model: ->
    @get('store').find('setting', 'all')
