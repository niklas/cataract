Cataract.SquareView = Ember.View.extend
  template: Ember.Handlebars.compile '{{view.size}}'
  attributeBindings: ['style']
  classNames: ['square']

  width: Ember.computed.alias('content.width')
  height: Ember.computed.alias('content.height')
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
      background-color: ##{@get('color')};
      """
    .property('width', 'height')
