Cataract.TorrentsController =
  Ember.ArrayController.extend Ember.PaginationSupport, Ember.SortableMixin,
  needs: ['application']

  mode:         Ember.computed.alias  'controllers.application.mode'
  age:          Ember.computed.alias  'controllers.application.age'
  poly:         Ember.computed.alias  'controllers.application.poly'
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
    @set 'content', @get('store').filter 'torrent', (torrent)->
      # do not have to requery the server after deletion of torrent
      ! torrent.get('isDeleted')
    @gotoFirstPage()
    @refreshTransfers()
  ).on('init')

  # we use our current queryParams, fetch its torrents to fill the DS cache as
  # a side effect
  warmupStore: (->
    console?.debug "warming up...."
    store = @get('store')
    # TODO fetch only torrents having content if status is 'library'

    # save that just to be able to wait in a route
    @set 'loadedContent', store.findQuery('torrent', age: @get('age')).then => @didRequestRange()
  ).on('init')

  freshTransfersOnTick: (->
    @refreshTransfers()
    true
  ).on('init')



  # we will sort, filter, paginate
  # resulting in a update of 'finalContent'
  finalContent: Ember.computed.defaultTo('content')

  #######################################################################
  # Sorting
  #######################################################################
  sortAscending: false
  sortProperties:
    Ember.computed ->
      switch @get('mode')
        when 'library' then ['payloadKiloBytes']
        else ['createdAt']
    .property('mode')
  # results in sorted 'content' in 'arrangedContent'


  #######################################################################
  # Filter
  #######################################################################

  termsList:
    Ember.computed ->
      if terms = @get('terms')
        Ember.A( Ember.String.w(terms)).map (x) -> x.toLowerCase()
      else
        Ember.A()
    .property('terms')

  filterFunction:
    Ember.computed ->
      console?.debug "filterfunc"
      termsList  = @get('termsList')
      mode = @get('mode') || ''
      age = @get('age') || ''
      directoryIds = @get('directoryIds') || []
      directoryId = @get('directory.id')

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

        if age.length > 0
          sinceDate = switch age
            when 'month' then moment().subtract(1, 'month')
            when 'year' then moment().subtract(1, 'year')
            else
              if m = age.match(/^month(\d+)$/)
                moment().subtract( parseInt(m[1], 10), 'month')
          if sinceDate
            want = want and torrent.get('updatedAt') > sinceDate

        if directoryIds.length > 0 and torrent.get('contentDirectory.isLoaded')
          want = want and directoryIds.indexOf( torrent.get('contentDirectory.id') ) >= 0

        if directoryId?
          want = want and torrent.get('contentDirectory.id') == directoryId

        console?.log "want", want
        want
    .property('termsList', 'mode', 'directory', 'age', 'directoryIds.@each', 'directories')

  filterFunctionDidChange: (->
    console.debug 'filterFunctionDidChange'
    @gotoFirstPage()
    # wait for old views to be destroyed
    @didRequestRange()
  ).observes("filterFunction")

  filteredContent:
    Ember.computed ->
      console?.debug "filteredContent"
      @get('arrangedContent').filter( @get('filterFunction') )
    .property('termsList', 'mode', 'directory', 'age', 'directoryIds.@each', 'filterFunction', 'arrangedContent.@each.id', 'arrangedContent.@each.status', 'arrangedContent.@each')

  filteredContentDidChange: (->
    Ember.run.once => @didRequestRange()
  ).observes('filteredContent')


  #######################################################################
  # Paginate
  #######################################################################

  totalBinding: 'fullContent.length'
  rangeWindowSize: 50

  didRequestRange: ->
    console?.debug "final"
    rangeStart = @get('rangeStart')
    rangeStop = @get('rangeStop')
    content = @get('filteredContent').slice(rangeStart, rangeStop)
    @set 'finalContent', content
    @refreshTransfers()



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

    fetch.then (transfers) ->
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
      Cataract.set 'online', true
      true
    , (x,y)->
      console?.debug 'could not fetch transfers:', x.responseText

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
