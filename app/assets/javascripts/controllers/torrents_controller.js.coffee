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
    directory = @get('directory')
    (torrent) ->
      want = true
      torrent = torrent.record if torrent.record? # materialized or not?!
      text = "#{torrent.get('title')} #{torrent.get('filename')}".toLowerCase()
      want = want and termsList.every (term) -> text.indexOf(term) >= 0

      if mode.length > 0
        if mode == 'running'
          want = want and torrent.get('status') == 'running'

      if directory
        want = want and directory is torrent.get('contentDirectory')

      want
  ).property('termsList', 'mode', 'directory', 'age')


  siteTitle: (->
    title = "#{@get('mode')} torrents"
    if @get('terms').length > 0
      title += " containing '#{@get('terms')}'"
    if @get('directory')
      title += " in \"#{@get('directory').get('name')}\""
    title
  ).property('terms', 'mode', 'directory')

  reload: ->
    @set 'unfilteredContent', Cataract.Torrent.find(age: @get('age'))

  didAddRunningTorrent: (torrent) ->
    @set('mode', 'running')
    @reload()
    Cataract.Router.router.transitionTo 'torrent', torrent


  refreshTransfers: ->
    list = @get('unfilteredContent')
    running = list.filterProperty('status', 'running')
    primaryKey = Emu.Model.primaryKey(Cataract.Transfer)
    store = Ember.get(Emu, "defaultStore")
    serializer = store._adapter._serializer
    existing = Cataract.get('transfers')
    $.getJSON "/transfers?running=#{running.mapProperty('id').join(',')}", (data, textStatus, xhr) ->
      for update in data
        if transfer = existing.findProperty('id', update[primaryKey])
          serializer.deserializeModel(transfer, update, true) # update without making it dirty
        else
          transfer = Cataract.Transfer.createRecord update
        if torrent = store.findUpdatable(Cataract.Torrent, update[primaryKey])
          torrent.set 'status', 'running'
          # TODO detect stopped torrents
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
