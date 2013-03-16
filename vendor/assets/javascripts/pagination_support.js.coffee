get = Ember.get

###
@extends Ember.Mixin

Implements common pagination management properties for controllers.
###
Ember.PaginationSupport = Ember.Mixin.create
  hasPaginationSupport: true
  total: 0
  rangeStart: 0
  rangeWindowSize: 10
  didRequestRange: Ember.K
  rangeStop: Ember.computed ->
    rangeStop = get(this, "rangeStart") + get(this, "rangeWindowSize")
    total = get(this, "total")
    return rangeStop  if rangeStop < total
    total
  .property("total", "rangeStart", "rangeWindowSize").cacheable()
  hasPrevious: Ember.computed ->
    get(this, "rangeStart") > 0
  .property("rangeStart").cacheable()
  hasNext: Ember.computed ->
    get(this, "rangeStop") < get(this, "total")
  .property("rangeStop", "total").cacheable()
  nextPage: ->
    @incrementProperty "rangeStart", get(this, "rangeWindowSize")  if get(this, "hasNext")

  previousPage: ->
    @decrementProperty "rangeStart", get(this, "rangeWindowSize")  if get(this, "hasPrevious")

  page: Ember.computed ->
    (get(this, "rangeStart") / get(this, "rangeWindowSize")) + 1
  .property("rangeStart", "rangeWindowSize").cacheable()
  totalPages: Ember.computed ->
    Math.ceil get(this, "total") / get(this, "rangeWindowSize")
  .property("total", "rangeWindowSize").cacheable()
  pageDidChange: (->
    @didRequestRange get(this, "rangeStart"), get(this, "rangeStop")
  ).observes("total", "rangeStart", "rangeStop")
  gotoFirstPage: -> @set('rangeStart', 0)
