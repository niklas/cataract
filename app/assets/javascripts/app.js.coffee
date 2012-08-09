Cataract = Ember.Application.create

Cataract.store = DS.Store.create
  revision: 4
  adapter: DS.RESTAdapter.create
    bulkCommit: false


window.Cataract = Cataract
