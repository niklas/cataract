Cataract.Router.map ->
  @route 'add', path: '/add'
  @resource 'torrent', path: '/torrent/:torrent_id'
  @resource 'directory', path: '/directory/:directory_id'
  @route 'disk', path: 'disk/:disk_id'
  @route 'new_directory', path: 'directory/new'
  @route 'settings'
  @route 'running'
  @route 'recent'
  @route 'library', ->
    @resource 'directory', path: 'directory/:directory_id', ->
      @route 'online'
      @route 'detect'
      @route 'children'
    @resource 'disk', path: 'disk/:disk_id'

Cataract.TorrentsRoute = Ember.Route.extend
  renderTemplate: ->
    # we are always rendered
    # but the directory maybe, depends on query-params available later
    @render 'directory',
      controller: @controllerFor('directory')

Cataract.DetailedRoute = Ember.Route.extend
  setupController: (controller, model)->
    @_super(controller, model)
    @controllerFor('application').set 'detailsRouteActive', true
  deactivate: ->
    @_super()
    @controllerFor('application').set 'detailsRouteActive', false
  renderTemplate: ->
    @render outlet: 'details'


# TODO have to think about these routes vs queryParams

Cataract.TorrentRoute = Cataract.DetailedRoute.extend
  beforeModel: ->
    @controllerFor('torrents').get('loadedContent') # waiting for promise to resolve
  model: (params) ->
    @get('store').find 'torrent', params.torrent_id

  renderTemplate: ->
    @_super()
    @render 'torrents/running'

Cataract.NewDirectoryRoute = Ember.Route.extend
  model: ->
    @get('store').createRecord 'directory',
      disk: @modelFor('disk')
      parentDirectory: @controllerFor('torrents').get('directory')
      virtual: false

  setupController: (controller, model) ->
    @_super(controller, model)
    @send 'openModal', 'create_directory', model

Cataract.SettingsRoute = Cataract.DetailedRoute.extend
  model: ->
    @get('store').find('setting', 'all')
