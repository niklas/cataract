Cataract.SquareView = Ember.View.extend
  template: Ember.Handlebars.compile '{{view.size}}'
  attributeBindings: ['style']

  width: Ember.computed.alias('content.width')
  height: Ember.computed.alias('content.height')
  size: Ember.computed.alias('content.size')

  color:
    Ember.computed ->
      '' + Math.round(Math.random() * 999999)
    .property('size')

  style:
    Ember.computed ->
      """
      width: #{@get('width')}px;
      height: #{@get('height')}px;
      background-color: ##{@get('color')};
      """
    .property('width', 'height')
