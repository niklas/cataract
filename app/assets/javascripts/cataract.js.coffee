#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require_tree ./routes
Ember.LOG_BINDINGS = true

Cataract = Ember.Application.create
  rootElement: '#container'

Cataract.store = DS.Store.create
  revision: 4
  adapter: DS.RESTAdapter.create
    bulkCommit: false
    plurals:
      directory: 'directories'


window.Cataract = Cataract

jQuery -> Cataract.initialize()
