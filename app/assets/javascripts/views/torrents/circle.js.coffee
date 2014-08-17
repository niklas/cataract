Cataract.CircleTorrentView = Ember.View.extend
  templateName: 'torrents/circle'
  classNames: ['payload_circle']
  attributeBindings: ['style']

  limit: 50
  max: Ember.computed.alias('controller.maxPayloadKiloBytes')
  factor:
    Ember.computed ->
      @get('limit') / @get('max')
    .property('limit', 'max')
  tagName: 'li'

  logBytes:
    Ember.computed ->
      if bytes = @get('content.payloadKiloBytes')
        Math.log bytes
      else
        0
    .property('content.payloadKiloBytes')

  diameter:
    Ember.computed ->
      @get('logBytes') * @get('factor')
    .property('logBytes', 'factor')

  style:
    Ember.computed ->
      diameter = Math.round @get('diameter')
      """
      width: #{diameter}px;
      height: #{diameter}px;
      line-height: #{diameter}px;
      -foo-limit: #{@get('limit')};
      -foo-max: #{@get('max')};
      -foo-factor: #{@get('factor')};
      """
    .property('diameter')
