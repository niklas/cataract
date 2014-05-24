Cataract.SquareView = Ember.View.extend
  template: Ember.Handlebars.compile '{{view.size}}'
  attributeBindings: ['style']
  classNames: ['square']

  width: Ember.computed.alias('content.width')
  height: Ember.computed.alias('content.height')
  top: Ember.computed.alias('content.top')
  left: Ember.computed.alias('content.left')
  size: Ember.computed.alias('content.size')

  color:
    Ember.computed ->
      ('' + Math.pow(@get('size'),23.5) ).slice(0,6)
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
