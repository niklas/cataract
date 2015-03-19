Cataract.TorrentsListComponent = Ember.Component.extend
  content: []
  mode: 'unknown'

  tagName: "ul"
  elementId: "torrents"
  classNames: ["torrents", "clearfix"]

  wantsCircleView: Ember.computed.equal 'mode', 'library'
