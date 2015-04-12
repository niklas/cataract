attr = DS.attr
Cataract.Feed = DS.Model.extend
  title: attr 'string'
  url:   attr 'string'

  remoteTorrents: Ember.computed 'url', ->
    @get('store').find 'remote-torrent', feed_id: @get('id')
