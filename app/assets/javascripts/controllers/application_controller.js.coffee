Cataract.ApplicationController = Ember.Controller.extend
  setupTitle: (->
    Ember.run.next =>
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
  path: undefined
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

  # The currently available disks depending on the path from queryParams
  disks: Ember.computed 'poly', 'poly.@each.alternatives.disk', ->
    if @get('poly')
      @get('poly.alternatives').mapProperty('disk')
    else
      @get('controllers.disks')

  # 'disk' is just the id from the query params
  diskObject: Ember.computed 'disk', ->
    @get('store').find 'disk', @get('disk')

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

  fetchTorrentsForChange: (change='age')->
    console?.debug "will fetch because changes on", change
    if torrents = @get('controllers.torrents')
      switch change
        when 'age'
          if age = @get('age')
            torrents.fetch(age: age)
        when 'directory'
          if directory = @get('directory')
            torrents.fetch(directory_id: directory.id, with_content: true)
          else
            console?.warn 'no directory found to fetch'
        when 'poly'
          if poly = @get('poly')
            dirIds = poly.get('alternatives').mapProperty('id')
            if dirIds.length > 0
              torrents.fetch(directory_id: dirIds.join(','), with_content: true)
          else
            console?.warn 'no poly found to fetch'
    else
      console?.warn 'need controllers.torrents, but not found'


  observeAndScheduleFetchTorrents: ( (val, prop)->
    Ember.run.scheduleOnce 'actions', this, this.fetchTorrentsForChange, prop
  ).observes('age', 'directory', 'poly')
