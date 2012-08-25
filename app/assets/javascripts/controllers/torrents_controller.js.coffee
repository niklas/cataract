Cataract.TorrentsController = Ember.ArrayController.extend
  terms: null
  status: 'recent'
  content: (->
    Cataract.store.find(Cataract.Torrent, status: @get('status'), per: 900)
  ).property('status', 'terms')

