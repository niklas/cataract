Cataract.SquareView = Ember.View.extend
  template: Ember.Handlebars.compile '{{#unless view.tooSmall}}{{view.size}}{{/unless}}'
  attributeBindings: ['style', 'hoverTitle:title']
  classNames: ['square']

  width: Ember.computed.alias('content.width')
  height: Ember.computed.alias('content.height')
  top: Ember.computed.alias('content.top')
  left: Ember.computed.alias('content.left')
  size: Ember.computed.alias('content.size')

  tooSmall:
    Ember.computed ->
      @get('width') < 50 or @get('height') < 50
    .property('width', 'height')

  hoverTitle:
    Ember.computed ->
      if @get('tooSmall')
        @get('size')
    .property('tooSmall', 'size')

  color:
    Ember.computed ->
      ('' + Math.pow(@get('size') + 2.15,23.5) ).replace(/\D/g,'').slice(0,6)
    .property('size')

  style:
    Ember.computed ->
      """
      width: #{@get('width')}px;
      height: #{@get('height')}px;
      top: #{@get('top')}px;
      left: #{@get('left')}px;
      background-color: ##{@get('color')};
      """
    .property('width', 'height', 'top', 'left')
