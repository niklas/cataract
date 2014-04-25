Cataract.TorrentsController = Cataract.FilteredController.extend Ember.PaginationSupport,
  needs: ['application', 'disks', 'directories']

  modeBinding: 'controllers.application.mode'
  ageBinding: 'controllers.application.age'
  polyBinding: 'controllers.application.poly'
  directoriesBinding: 'controllers.application.directories'
  directoryBinding: 'controllers.application.directory'

  init: ->
    @_super()
    $('body').bind 'tick', => @refreshTransfers(); true

  unfilteredContent: Ember.A()

  fullContentBinding: 'filteredContent'
  totalBinding: 'fullContent.length'
  # TODO i18n
  # human readable current age
  describedAge:
    Ember.computed ->
      if @get('age') == 'all'
        "All since ever"
      else
        "in this " + @get('age')
    .property('age')

  rangeWindowSize: 50

  didRequestRange: (rangeStart, rangeStop) ->
    content = @get('fullContent').slice(rangeStart, rangeStop)
    @set 'model', content # route sets unfilteredContent

  # TODO terms as query-param?
  termsBinding: 'Cataract.terms'
  directoryIds: Ember.computed.mapProperty 'directories', 'id'

  filterFunctionDidChange: (->
    @gotoFirstPage()
    @didRequestRange @get("rangeStart"), @get("rangeStop")
  ).observes("filterFunction", 'mode')

  termsList:
    Ember.computed ->
      if terms = @get('terms')
        Ember.A( Ember.String.w(terms)).map (x) -> x.toLowerCase()
      else
        Ember.A()
    .property('terms')


  filterFunction: (->
    termsList  = @get('termsList')
    mode = @get('mode') || ''
    directoryIds = @get('directoryIds') || []
    directoryId = @get('directory.id')

    (torrent) ->
      want = true
      torrent = torrent.record if torrent.record? # materialized or not?!
      text = "#{torrent.get('title')} #{torrent.get('filename')}".toLowerCase()
      want = want and termsList.every (term) -> text.indexOf(term) >= 0

      if mode.length > 0
        if mode == 'running'
          want = want and torrent.get('status') == 'running'

      if directoryIds.length > 0 and torrent.get('contentDirectory.isLoaded')
        want = want and directoryIds.indexOf( torrent.get('contentDirectory.id') ) >= 0

      if directoryId?
        want = want and torrent.get('contentDirectory.id') == directoryId

      want
  ).property('termsList', 'mode', 'directory', 'age', 'directoryIds.@each')


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

  refreshTransfers: ->
    list = @get('unfilteredContent')
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

  setAge: (age) ->
    @set 'age', age
    @reload()
    age

  isRecentActive:
    Ember.computed ->
      @get('mode') is 'recent'
    .property('mode')
  isRunningActive:
    Ember.computed ->
      @get('mode') is 'running'
    .property('mode')
