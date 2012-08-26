Cataract.TorrentsController = Ember.ArrayController.extend
  terms: ''
  status: ''
  setSiteTitle: (->
    title = "#{@get('status')} torrents"
    if @get('terms').length > 0
      title += " containing '#{@get('terms')}'"
    if @get('directory')
      title += " in \"#{@get('directory').get('name')}\""
    Cataract.set 'siteTitle', title
  ).observes('filterFunction')

  filterFunction: (->
    terms  = Ember.A( Ember.String.w(@get('terms')) ).map (x) -> x.toLowerCase()
    status = @get('status')
    (torrent) ->
      want = true
      text = "#{torrent.get('title')} #{torrent.get('filename')}".toLowerCase()
      want = want and terms.every (term) -> text.indexOf(term) >= 0

      if status.length > 0 and status == 'running'
        want = want and torrent.get('isRunning')

      want
  ).property('terms', 'status')

  content: (->
    Cataract.store.filter(Cataract.Torrent, @get('filterFunction'))
  ).property('filterFunction')

