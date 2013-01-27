Cataract.TorrentsController = Ember.ArrayController.extend
  pureContent: []
  content: (->
    @get('pureContent').filter( @get('filterFunction') )
  ).property('filterFunction', 'pureContent.@each')

  termsBinding: 'Cataract.terms'
  mode: ''

  filterFunction: (->
    terms  = Ember.A( Ember.String.w(@get('terms')) ).map (x) -> x.toLowerCase()
    mode = @get('mode')
    (torrent) ->
      want = true
      torrent = torrent.record if torrent.record? # materialized or not?!
      text = "#{torrent.get('title')} #{torrent.get('filename')}".toLowerCase()
      want = want and terms.every (term) -> text.indexOf(term) >= 0

      if mode.length > 0
        if mode == 'running'
          want = want and torrent.get('status') == 'running'

      if directory = Cataract.get('currentDirectory')
        want = want and directory is torrent.get('contentDirectory')

      want
  ).property('terms', 'mode', 'Cataract.currentDirectory')


  siteTitle: (->
    title = "#{@get('mode')} torrents"
    if @get('terms').length > 0
      title += " containing '#{@get('terms')}'"
    if @get('directory')
      title += " in \"#{@get('directory').get('name')}\""
    title
  ).property('terms', 'mode', 'directory')
