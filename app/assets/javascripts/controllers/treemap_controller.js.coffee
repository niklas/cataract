Cataract.TreemapController = Ember.ObjectController.extend
  fillOnInit: (->
    list = @get('objects')
    for n in [ 5000, 9000, 12000, 1200, 400, 5000, 800 ]
      list.pushObject Ember.Object.create(size: n)
  ).on('init')

  objects: Ember.A()

  width: 700
  height: 500

  didChangeObjects: (->
    console?.debug "starting with #{@get('objects.length')} objects"

    objects = @get('objects')
    return if objects.length is 0
    # TODO scale values => pixel
    width = @get('width')
    height = @get('height')
    direction = if width > height then 1 else 0

    worst = (row, w)->
      return -1 if row.length is 0
      values = row.mapProperty('size')
      min = values.reduce (m, x)-> if m < x then m else x
      max = values.reduce (m, x)-> if m > x then m else x
      sum = values.reduce (s, x)-> s + x

      Math.max (max * w**2)/(sum**2), (sum**2)/(min * w**2)

    shortestWidth = ->
      Math.min width, height

    layoutRow = (row)->
      area = row.mapProperty('size').reduce (s, x)-> s + x
      h = shortestWidth()
      w  = area / h
      for item in row
        size = item.get('size')
        h = size / w
        if direction is 0
          item.set('height', h)
          item.set('width',   w)
        else
          item.set('height',  w)
          item.set('width',  h)

      if direction is 0
        width = width - w
      else
        height = height - w

      direction = 1 - direction # switch vertical/horizontal


    squarify = (children, row, w)->
      return if children.length is 0
      c = children.get('firstObject')

      fit = row.concat(c)
      if worst(row, w) <= worst( fit, w)
        squarify( children.slice(1), fit, w )
      else
        layoutRow(row)
        squarify( children, Ember.A(), shortestWidth() )

    squarify objects, Ember.A(), shortestWidth()

  ).observes('objects.@each')

  actions:
    addOne: ->
      n = Math.round( Math.random() * 10000 )
      @get('objects').pushObject Ember.Object.create(size: n)

