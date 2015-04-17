Cataract.TorrentsController =
  Ember.ArrayController.extend Ember.PaginationSupport, Ember.SortableMixin,
  needs: ['application']

  mode:         Ember.computed.alias  'controllers.application.mode'
  age:          Ember.computed.alias  'controllers.application.age'
  poly:         Ember.computed.alias  'controllers.application.poly'
  disk:         Ember.computed.alias  'controllers.application.disk'

  # TODO remove?
  directories:  Ember.computed.alias  'controllers.application.directories'
  directory:    Ember.computed.alias  'controllers.application.directory'
  directoryIds: Ember.computed.mapProperty 'directories', 'id'

  # TODO terms as query-param?
  terms:        Ember.computed.alias 'controllers.application.terms'

  #######################################################################
  # Initialization
  #######################################################################

  # because the torrents list is always rendered (and should contain items), we
  # cannot wait for the route to setup the content of it.
  initializeContent: (->
    fn = @get('filterFunction') # consume so observers fire
    @set 'model', @get('store').filter 'torrent', (torrent)->
      # do not have to requery the server after deletion of torrent
      ! torrent.get('isDeleted')
  ).on('init')

  # we use our current queryParams, fetch its torrents to fill the DS cache as
  # a side effect
  warmupStore: ->
    console?.debug "warming up...."
    store = @get('store')
    # TODO fetch only torrents having content if status is 'library'

    Ember.run => # pause all observers while the JSON response is processed
      # save that just to be able to wait in a route
      @set 'loadedContent', store.findQuery('torrent', age: @get('age')).then =>
        @gotoFirstPage()

  freshTransfersOnTick: (->
    @refreshTransfers()
    true
  ).on('init')

  # OPTIMIZE where is the best place for this?
  reactToModelChanges: (->
    store = @get('store')
    @get('serverEvents.source').addEventListener 'torrent', (event)->
      parsed = JSON.parse(event.data)
      if id = parsed.id
        store.find('torrent', id).then (torrent)->
          torrent.sideUpdateAttributes(parsed)

  ).on('init')



  # we will sort, filter, paginate
  # resulting in a update of 'finalContent'
  finalContent: Ember.computed.oneWay('content')

  #######################################################################
  # Sorting
  #######################################################################
  sortAscending: false
  sortProperties:
    Ember.computed 'mode', ->
      switch @get('mode')
        when 'library' then ['payloadKiloBytes']
        else ['createdAt']
  # results in sorted 'content' in 'arrangedContent'


  #######################################################################
  # Filter
  #######################################################################

  termsList:
    Ember.computed 'terms', ->
      if terms = @get('terms')
        Ember.A( Ember.String.w(terms)).map (x) -> x.toLowerCase()
      else
        Ember.A()

  filterFunction:
    Ember.computed 'termsList', 'mode', 'age', 'poly', 'disk', ->
      console?.debug "filterfunc"
      termsList  = @get('termsList')
      mode       = @get('mode') || ''
      age        = @get('age') || ''
      poly       = @get('poly')
      diskId     = @get('disk')

      directoryIds = poly?.get('alternatives')?.mapProperty('id') || []

      if age.length > 0
        sinceDate = switch age
          when 'month' then moment().subtract(1, 'month')
          when 'year' then moment().subtract(1, 'year')
          else
            if m = age.match(/^month(\d+)$/)
              moment().subtract( parseInt(m[1], 10), 'month')

      (torrent) ->
        want = true
        torrent = torrent.record if torrent.record? # materialized or not?!
        text = "#{torrent.get('title')} #{torrent.get('filename')}".toLowerCase()
        want = want and termsList.every (term) -> text.indexOf(term) >= 0

        if mode.length > 0
          switch mode
            when 'running'
              want = want and torrent.get('status') is 'running'
            when 'library'
              want = want and torrent.get('payloadExists')

          unless mode is 'library'
            if sinceDate
              want = want and torrent.get('updatedAt') > sinceDate

        if directoryIds.length > 0 and torrent.get('contentDirectory.isLoaded')
          want = want and directoryIds.indexOf( torrent.get('contentDirectory.id') ) >= 0

        if diskId? and torrent.get('contentDirectory.isLoaded')
          want = want and torrent.get('contentDirectory.disk.id') == diskId

        want

  filterFunctionDidChange: (->
    console.debug 'filterFunctionDidChange'
    @gotoFirstPage()
    # wait for old views to be destroyed
    @didRequestRange()
  ).observes("filterFunction")

  filteredContent:
    Ember.computed 'termsList', 'mode', 'directory', 'age', 'directoryIds.@each', 'filterFunction', 'arrangedContent.@each.id', 'arrangedContent.@each.status', 'arrangedContent.@each', ->
      console?.debug "filteredContent"
      @get('arrangedContent').filter( @get('filterFunction') )

  #######################################################################
  # Paginate
  #######################################################################

  total: Ember.computed.alias 'filteredContent.length'
  rangeWindowSize: 50

  didRequestRange: ->
    rangeStart = @get('rangeStart')
    rangeStop = @get('rangeStop')
    content = @get('filteredContent').slice(rangeStart, rangeStop)
    @set 'finalContent', content



  #######################################################################
  # Other
  #######################################################################

  siteTitle: (->
    title = "#{@get('mode')} torrents"
    if @get('terms').length > 0
      title += " containing '#{@get('terms')}'"
    if @get('directory')
      title += " in \"#{@get('directory').get('name')}\""
    title
  ).property('terms', 'mode', 'directory')

  didAddRunningTorrent: (torrent) ->
    @set('mode', 'running')
    @reload()
    @refreshTransfers()
    Cataract.Router.router.transitionTo 'torrent', torrent

  # TODO treat transfers as a normal model with infoHash as foreign key
  refreshTransfers: ->
    list = @get('content') # unfiltered, but sorted
    running = list.filterProperty('status', 'running').mapProperty('id')
    store = @get('store')
    existing = store.find
    fetch = store.findQuery 'transfer', running: running.join(',')

    fetch.then (transfers) =>
      # time as passed => recalculate
      running = list.filterProperty('status', 'running').mapProperty('id')
      transfers.forEach (transfer)->
        id = transfer.get('id')
        if torrent = list.findProperty('id', id)
          torrent.set 'status', if transfer.get('active') then 'running' else 'archived'
          torrent.set('transfer', transfer)
        running.removeObject(id)

      # detect stopped torrents
      running.forEach (disap) ->
        if torrent = list.findProperty('id', disap)
          torrent.set 'status', 'archived'
          torrent.set 'transfer', null
      @get('controllers.application').transfersSuccess()
      true
    , (jqxhr)=>
      @get('controllers.application').transfersError(jqxhr)

  isRecentActive:
    Ember.computed ->
      @get('mode') is 'recent'
    .property('mode')
  isRunningActive:
    Ember.computed ->
      @get('mode') is 'running'
    .property('mode')

  payloadSizes: Ember.computed.mapBy 'content', 'payloadKiloBytes'
  maxPayloadKiloBytes: Ember.computed.max('payloadSizes')
