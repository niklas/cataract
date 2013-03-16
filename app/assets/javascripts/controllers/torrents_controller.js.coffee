Cataract.TorrentsController = Cataract.FilteredController.extend Ember.PaginationSupport,
  unfilteredContent: Cataract.Torrent.find()

  fullContentBinding: 'filteredContent'
  totalBinding: 'fullContent.length'
  rangeWindowSize: 50

  didRequestRange: (rangeStart, rangeStop) ->
    content = @get('fullContent').slice(rangeStart, rangeStop)
    @replace 0, @get('length'), content

  termsBinding: 'Cataract.terms'
  mode: ''
  directoryBinding: 'Cataract.currentDirectory'

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
  ).property('termsList', 'mode', 'directory')


  siteTitle: (->
    title = "#{@get('mode')} torrents"
    if @get('terms').length > 0
      title += " containing '#{@get('terms')}'"
    if @get('directory')
      title += " in \"#{@get('directory').get('name')}\""
    title
  ).property('terms', 'mode', 'directory')
