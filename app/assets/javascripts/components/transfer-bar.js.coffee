Cataract.TransferBarComponent = Ember.Component.extend
  content: null

  # can be specified, but they default to the content's props
  progress:    Ember.computed.oneWay 'content.progress'
  downRate:    Ember.computed.oneWay 'content.downRate'
  upRate:      Ember.computed.oneWay 'content.upRate'
  eta:         Ember.computed.oneWay 'content.eta'
  message:     Ember.computed.oneWay 'content.message'

