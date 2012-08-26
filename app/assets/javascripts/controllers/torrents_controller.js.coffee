Cataract.TorrentsController = Ember.ArrayController.extend
  terms: ''
  status: 'recent'
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

