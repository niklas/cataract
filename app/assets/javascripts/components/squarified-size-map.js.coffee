JustSizeView = Ember.View.extend
  template: Ember.Handlebars.compile '{{#unless tooSmall}}{{size}}{{/unless}}'

Cataract.SquarifiedSizeMapComponent = Ember.Component.extend
  classNames: ['treemap']
  attributeBindings: ['style']
  objects: Ember.A()
  itemViewClass: JustSizeView
  sizeProperty: 'size'

  width: 600
  height: 400
  isRunning: false

  styleTag:
    Ember.computed ->
      id = @get('elementId')
      """
        <style>
        ##{id} .square {
                width: 1px;
                height: 1px;
                top: 100%;
                left: 100%;
                position: absolute;
                overflow: hidden;
                transition: top 0.5s, left 0.5s, width 0.4s, height 0.4s;
        }
        ##{id} button {
                position: absolute;
                top: 0;
                left: 0;
                z-index: 5;
        }
        </style>
      """
    .property('elementId')

  style:
    Ember.computed ->
      """
      position: relative;
      overflow: hidden;
      width: #{@get('width')}px;
      height: #{@get('height')}px;
      """
    .property('width', 'height')

  didChangeObjects: (->
    Ember.run.debounce this, 'buildTreeMap', 150
  ).observes('objects.@each')


  buildTreeMap: ->
    return if @get('isRunning')
    @set('isRunning', true)
    console?.debug "starting with #{@get('objects.length')} objects"
    sizeProp = @get('sizeProperty')

    objects = @get('objects').filter (e)-> e.get(sizeProp) isnt 0
    return if objects.length is 0
    objects = objects.sortBy(sizeProp).reverse()

    sumOf = (list)-> list.mapProperty(sizeProp).reduce ((s,x)-> s+x), 0
    sqrt = Math.sqrt

    pixelWidth = @get('width')
    pixelHeight = @get('height')
    allPixels = pixelWidth * pixelHeight
    console?.debug "Pixels: #{pixelWidth}x#{pixelHeight} = #{allPixels}"
    allSize = sumOf objects
    scale = sqrt(allSize) / sqrt(allPixels)
    width  = pixelWidth * scale
    height = pixelHeight * scale
    console?.debug "Size: #{width}x#{height} = #{allSize}"
    widthInPixels  = (w)-> w / scale
    heightInPixels = (w)-> w / scale
    direction = if width < height then 1 else 0
    currentTop = 0
    currentLeft = 0



    worst = (row, w)->
      return Number.MAX_VALUE if row.length is 0
      values = row.mapProperty(sizeProp)
      min = values.reduce ((m, x)-> if m < x then m else x),  Number.MAX_VALUE
      max = values.reduce ((m, x)-> if m > x then m else x),  0
      sum = values.reduce (s,x)->s+x

      sqw = w**2
      sqsum = sum**2
      Math.max (max * sqw)/sqsum, sqsum/(min * sqw)

    shortestWidth = ->
      console?.debug "shortest of", width, height
      Math.min width, height

    layoutRowVertically = (row)->
      area = sumOf row
      h = height
      w  = area / h
      offset = currentTop
      console?.debug "layouting #{row.length} items vertically (#{area}=#{h}x#{w})"
      for item in row
        size = item.get(sizeProp)
        h = size / w
        item.set('width',  widthInPixels w)
        item.set('height', heightInPixels h)
        item.set('left',  widthInPixels currentLeft)
        item.set('top',  heightInPixels offset)
        offset += h
      width -= w
      currentLeft += w

    layoutRowHorizontally = (row)->
      area = sumOf row
      h = width
      w  = area / h
      offset = currentLeft
      console?.debug "layouting #{row.length} items horizontally  (#{area}=#{h}x#{w})"
      for item in row
        size = item.get(sizeProp)
        h = size / w
        item.set('width',  widthInPixels h)
        item.set('height', heightInPixels w)
        item.set('left',  widthInPixels offset)
        item.set('top',  heightInPixels currentTop)
        offset += h
      height -= w
      currentTop += w

    layoutRow = (row)->
      if direction is 0
        layoutRowVertically(row)
      else
        layoutRowHorizontally(row)
      direction = 1 - direction # switch vertical/horizontal


    squarify = (children, row, w)->
      if children.length is 0
        unless row.length is 0
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

    @set('isRunning', false)

  actions:
    addOne: ->
      n = Math.round( Math.random() * 100000 )
      @get('objects').pushObject Ember.Object.create(size: n)

Cataract.SquarifiedSizeMapComponentItemView = Ember.View.extend
  attributeBindings: ['style', 'title']
  classNames: ['square']

  width: Ember.computed.alias('controller.width')
  height: Ember.computed.alias('controller.height')
  top: Ember.computed.alias('controller.top')
  left: Ember.computed.alias('controller.left')
  title: Ember.computed.alias('controller.hoverTitle')

  style:
    Ember.computed ->
      """
      width: #{@get('width')}px;
      height: #{@get('height')}px;
      top: #{@get('top')}px;
      left: #{@get('left')}px;
      """
    .property('width', 'height', 'top', 'left')

Cataract.SquarifiedSizeMapComponentItemController = Ember.ObjectController.extend
  tooSmall:
    Ember.computed ->
      @get('width') < 50 or @get('height') < 50
    .property('width', 'height')

  hoverTitle:
    Ember.computed ->
      if @get('tooSmall')
        @get('size')
    .property('tooSmall', 'size')
