Cataract.ApplicationController = Ember.Controller.extend
  setupTitle: (->
    Ember.run.later =>
      @get('fullSiteTitle') # observer does not fire if value is not used
      @propertyDidChange('fullSiteTitle')
  ).on('init')

  needs: ['torrents', 'directories', 'disks', 'transfers']

  fullSiteTitleObserver: ( (sender, key) ->
    $('head title').text(sender.get(key))
  ).observes('fullSiteTitle')

  fullSiteTitle:
    Ember.computed ->
      if sub = @get('controllers.torrents.siteTitle')
        [ sub, @get('siteTitle')].join(' - ')
      else
        "loading Cataract"
    .property('controllers.torrents.siteTitle')

  siteTitle: 'Cataract'

  # save these here to access from all controllers
  queryParams: [
    'age',
    'filterDirectories'
    'path',
    'disk',
    'adding',
    mode: 'status'
  ]
  mode: 'running'
  age: 'month' # faster initialization of page
  path: null
  disk: undefined
  adding: false
  filterDirectories: true
  terms: ''
  poly: Ember.computed 'path', ->
    @get('controllers.directories').findPolyByPath( @get('path') )
  directoriesBinding: 'poly.alternatives'

  # when poly has only one alternative or a the directory controller is active
  directory: Ember.computed 'directories.@each', 'disk', ->
    # by setting path through query params
    dirs = @get('directories')
    disk = @get('disk')

    dir = null
    if dirs
      if dirs.length is 1
        dir = dirs.get('firstObject')
      else
        dir = dirs.findProperty('disk.id', '' + disk)
    dir

  detailsRouteActive: false
  detailsExtended: Ember.computed.alias('detailsRouteActive')

  # TODO i18n
  # human readable current age
  describedAge:
    Ember.computed ->
      if @get('age') == 'all'
        "All since ever"
      else
        "in this " + @get('age')
    .property('age')

  transfersError: (jqxhr)->
    status = @get 'transferStatus' # globally injected
    status.set 'online', false
    if jqxhr.responseText?
      status.set 'offlineReason', jqxhr.responseText

  transfersSuccess: ()->
    status = @get 'transferStatus' # globally injected
    status.set 'online', true
