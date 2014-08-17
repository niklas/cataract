Cataract.CircleTorrentView = Ember.View.extend
  templateName: 'torrents/circle'
  classNames: ['payload_circle']
  attributeBindings: ['style']
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
      @get('logBytes') * 5
    .property('logBytes')
  style:
    Ember.computed ->
      diameter = @get('diameter')
      """
      width: #{diameter}px;
      height: #{diameter}px;
      line-height: #{diameter}px;
      """
    .property('diameter')
