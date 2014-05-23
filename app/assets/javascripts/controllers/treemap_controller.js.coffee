Cataract.TreemapController = Ember.ObjectController.extend
  fillOnInit: (->
    list = @get('objects')
    for n in [ 5000, 9000, 12000, 1200, 400, 50, 50, 50, 5 ]
      list.pushObject Ember.Object.create(size: n)
  ).on('init')

  objects: Ember.A()

  width: 700
  height: 500

  didChangeObjects: (->
    console?.debug "starting with #{@get('objects.length')} objects"

    width = @get('width')
    height = @get('height')
    direction = if width > height then 1 else 0

    worst = (row, w)->
      values = row.mapProperty('size')
      min = values.reduce (m, x)-> if m < x then m else x
      max = values.reduce (m, x)-> if m > x then m else x
      s = values.reduce (s, x)-> s + x

      Math.max (max * w**2)/(s**2), (s**2)/(min * w**2)

    shortestWidth = ->
      Math.min width, height

    layoutRow = (row)->
      s = row.reduce (s, x)-> s + x
      height = shortestWidth()
      row.each (e)->
        h = height
        w = width


    squarify = (children, row, w)->
      c = children.get('firstObject')

      if worst(row, w) <= worst( row.clone().pushObject(c), w)
        squarify( children.slice(1), row.clone().pushObject(c), w )
      else
        layoutRow(row)
        squarify( children, Ember.A(), shortestWidth()

    squarify @get('objects'), Ember.A(), shortestWidth()

  ).observes('objects.@each')

  actions:
    addOne: ->
      n = Math.round( Math.random() * 10000 )
      @get('objects').pushObject Ember.Object.create(size: n)

