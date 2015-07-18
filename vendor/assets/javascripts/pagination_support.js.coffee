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
  .property("total", "rangeStart", "rangeWindowSize")
  hasPrevious: Ember.computed ->
    get(this, "rangeStart") > 0
  .property("rangeStart")
  hasNext: Ember.computed ->
    get(this, "rangeStop") < get(this, "total")
  .property("rangeStop", "total")

  page: Ember.computed ->
    (get(this, "rangeStart") / get(this, "rangeWindowSize")) + 1
  .property("rangeStart", "rangeWindowSize")
  totalPages: Ember.computed ->
    Math.ceil get(this, "total") / get(this, "rangeWindowSize")
  .property("total", "rangeWindowSize")
  pageDidChange: (->
    Ember.run.once this, @didRequestRange
  ).observes("total", "rangeStart")
  gotoFirstPage: -> @set('rangeStart', 0)
