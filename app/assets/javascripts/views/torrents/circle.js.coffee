Cataract.CircleTorrentView = Ember.View.extend
  templateName: 'torrents/circle'
  classNames: ['payload_circle']
  attributeBindings: ['style']

  maxWidth: 100
  max: Ember.computed.alias('controller.maxPayloadKiloBytes')

  logBytes:
    Ember.computed ->
      if bytes = @get('content.payloadKiloBytes')
        Math.log bytes
      else
        0
    .property('content.payloadKiloBytes')

  diameter:
    Ember.computed ->
      ( @get('logBytes') / Math.log(@get('max')) ) * @get('maxWidth')
    .property('logBytes', 'factor')

  style:
    Ember.computed ->
      diameter = Math.round @get('diameter')
      """
      width: #{diameter}px;
      height: #{diameter}px;
      line-height: #{diameter}px;
      -foo-limit: #{@get('maxWidth')};
      -foo-log: #{@get('logBytes')};
      -foo-max: #{@get('max')};
      """
    .property('diameter')
