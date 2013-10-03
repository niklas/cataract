Cataract.TorrentsController = Cataract.FilteredController.extend Ember.PaginationSupport,
  init: ->
    @_super()
    $('body').bind 'tick', => @refreshTransfers(); true

  unfilteredContent: Ember.A()

  fullContentBinding: 'filteredContent'
  totalBinding: 'fullContent.length'
  age: 'month' # faster initialization of page
  # TODO i18n
  # human readable current age
  describedAge: Ember.computed ->
    if @get('age') == 'all'
      "All since ever"
    else
      "in this " + @get('age')
  .property('age')

  rangeWindowSize: 50

  didRequestRange: (rangeStart, rangeStop) ->
    content = @get('fullContent').slice(rangeStart, rangeStop)
    @replace 0, @get('length'), content

  termsBinding: 'Cataract.terms'
  mode: ''
  directoryBinding: 'Cataract.currentDirectory'
  directoryIdsBinding: 'Cataract.currentDirectoryIds'

  filterFunctionDidChange: (->
    @gotoFirstPage()
    @didRequestRange @get("rangeStart"), @get("rangeStop")
  ).observes("filterFunction", 'mode')

  termsList: Ember.computed ->
    if terms = @get('terms')
      Ember.A( Ember.String.w(terms)).map (x) -> x.toLowerCase()
    else
      Ember.A()
  .property('terms')


  filterFunction: (->
    termsList  = @get('termsList')
    mode = @get('mode') || ''
    directoryIds = @get('directoryIds')
    directoryId = @get('directory.id')

    (torrent) ->
      want = true
      torrent = torrent.record if torrent.record? # materialized or not?!
      text = "#{torrent.get('title')} #{torrent.get('filename')}".toLowerCase()
      want = want and termsList.every (term) -> text.indexOf(term) >= 0

      if mode.length > 0
        if mode == 'running'
          want = want and torrent.get('status') == 'running'

      if directoryIds.length > 0
        want = want and directoryIds.indexOf( torrent.get('contentDirectoryId') ) >= 0

      if directoryId?
        want = want and torrent.get('contentDirectoryId') == directoryId

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

  reload: ->
    loaded = Cataract.Torrent.find(age: @get('age'))

    # FIXME Emu does not give us promises
    loaded.one 'didFinishLoading', =>
      @notifyPropertyChange('unfilteredContent')

    @set 'unfilteredContent', loaded

  didAddRunningTorrent: (torrent) ->
    @set('mode', 'running')
    @reload()
    @refreshTransfers()
    Cataract.Router.router.transitionTo 'torrent', torrent

  didDeleteTorrent: (torrent) ->
    list = @get('unfilteredContent')
    list.removeObject( list.findProperty('id', torrent.get('id')) )


  refreshTransfers: ->
    list = @get('unfilteredContent')
    running = list.filterProperty('status', 'running').mapProperty('id')
    primaryKey = Emu.Model.primaryKey(Cataract.Transfer)
    store = Ember.get(Emu, "defaultStore")
    serializer = store._adapter._serializer
    existing = Cataract.get('transfers')
    $.getJSON "/transfers?running=#{running.join(',')}", (data, textStatus, xhr) ->
      # time as passed => recalculate
      running = list.filterProperty('status', 'running').mapProperty('id')
      for update in data
        id = update[primaryKey]
        transfer = existing.findProperty('id', id) || Cataract.Transfer.createRecord(id: id)
        serializer.deserializeModel(transfer, update, true) # update without making it dirty
        if torrent = list.findProperty('id', id)
          torrent.set 'status', if transfer.get('active') then 'running' else 'archived'
          torrent.get('transfers').clear()
          torrent.get('transfers').pushObject(transfer)
        running.removeObject(id)
      # detect stopped torrents
      running.forEach (disap) ->
        if torrent = list.findProperty('id', disap)
          torrent.set 'status', 'archived'
      Cataract.set 'online', true
      true

  setAge: (age) ->
    @set 'age', age
    @reload()
    age

  isRecentActive: Ember.computed ->
    @get('mode') is 'recent'
  .property('mode')
  isRunningActive: Ember.computed ->
    @get('mode') is 'running'
  .property('mode')
