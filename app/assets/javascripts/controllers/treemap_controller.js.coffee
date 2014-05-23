Cataract.TreemapController = Ember.ObjectController.extend
  fillOnInit: (->
    list = @get('objects')
    for n in [ 5000, 9000, 12000, 1200, 400, 50, 50, 50, 5 ]
      list.pushObject Ember.Object.create(size: n)
  ).on('init')

  objects: Ember.A()

  didChangeObjects: (->
    console?.debug "starting with #{@get('objects.length')} objects"
  ).observes('objects.@each')

  actions:
    addOne: ->
      n = Math.round( Math.random() * 10000 )
      @get('objects').pushObject Ember.Object.create(size: n)

