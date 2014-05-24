Cataract.TreemapController = Ember.ObjectController.extend
  fillOnInit: (->
    @set(
      'objects',
      Ember.Object.create(size: n) for n in [ 6, 6, 4, 3, 2, 2, 1]
    )
  ).on('init')

  objects: Ember.A()

  width: 600
  height: 400

  style:
    Ember.computed ->
      """
      width: #{@get('width')}px;
      height: #{@get('height')}px;
      """
    .property('width', 'height')

  didChangeObjects: (->
    console?.debug "starting with #{@get('objects.length')} objects"

    objects = @get('objects')
    return if objects.length is 0

    sumOf = (list)-> list.mapProperty('size').reduce ((s,x)-> s+x), 0
    sqrt = Math.sqrt

    # TODO scale values => pixel
    pixelWidth = @get('width')
    pixelHeight = @get('height')
    allPixels = pixelWidth * pixelHeight
    console?.debug "Pixels: #{pixelWidth}x#{pixelHeight} = #{allPixels}"
    allSize = sumOf objects
    width  = pixelWidth * sqrt(allSize) / sqrt(allPixels)
    height = pixelHeight * sqrt(allSize) / sqrt(allPixels)
    console?.debug "Size: #{width}x#{height} = #{allSize}"
    widthInPixels  = (w)-> w * pixelWidth / width
    heightInPixels = (w)-> w * pixelHeight / height
    direction = if width < height then 1 else 0

    worst = (row, w)->
      return Number.MAX_VALUE if row.length is 0
      values = row.mapProperty('size').map (v)-> v/w
      min = values.reduce ((m, x)-> if m < x then m else x),  Number.MAX_VALUE
      max = values.reduce ((m, x)-> if m > x then m else x),  0
      sum = values.reduce (s,x)->s+x

      sqw = w**2
      sqsum = sum**2
      Math.max (max * sqw)/sqsum, sqsum/(min * sqw)

    shortestWidth = ->
      Math.min width, height

    layoutRowAsColumn = (row)->
      area = sumOf row
      h = shortestWidth()
      w  = area / h
      console?.debug "layouting #{row.length} items as column (#{area}=#{h}x#{w})"
      for item in row
        size = item.get('size')
        h = size / w
        item.set('height', heightInPixels h)
        item.set('width',  widthInPixels w)
      width -= w

    layoutRowAsRow = (row)->
      area = sumOf row
      h = shortestWidth()
      w  = area / h
      console?.debug "layouting #{row.length} items as row (#{area}=#{h}x#{w})"
      for item in row
        size = item.get('size')
        h = size / w
        item.set('height', heightInPixels w)
        item.set('width',  widthInPixels h)
      height -= w

    layoutRow = (row)->
      if direction is 0
        layoutRowAsColumn(row)
      else
        layoutRowAsRow(row)
      direction = 1 - direction # switch vertical/horizontal


    squarify = (children, row, w)->
      if children.length is 0
        if row.length is 0
          layoutRow(row) # last row
        return
      c = children.get('firstObject')

      fit = row.concat(c)
      if worst(row, w) >= worst( fit, w)
        squarify( children.slice(1), fit, w )
      else
        layoutRow(row)
        squarify( children, Ember.A(), shortestWidth() )

    squarify objects, Ember.A(), shortestWidth()

  ).observes('objects.@each')

  actions:
    addOne: ->
      n = Math.round( Math.random() * 10 )
      @get('objects').pushObject Ember.Object.create(size: n)

