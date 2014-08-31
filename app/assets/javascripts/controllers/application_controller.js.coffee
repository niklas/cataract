Cataract.ApplicationController = Ember.Controller.extend
  setupTitle: (->
    Ember.run.later =>
      @get('fullSiteTitle') # observer does not fire if value is not used
      @propertyDidChange('fullSiteTitle')
  ).on('init')

  needs: ['torrents', 'directories', 'disks', 'directory']

  fullSiteTitleObserver: ( (sender, key) ->
    $('head title').text(sender.get(key))
  ).observes('fullSiteTitle')

  fullSiteTitle:
    Ember.computed ->
      if sub = @get('controllers.torrents.siteTitle')
        [ sub, @get('siteTitle')].join(' - ')
      else
        "loading Cataract"
    .property('controllers.torrents.siteTitle')

  siteTitle: 'Cataract'

  # save these here to access from all controllers
  queryParams: [
    'mode:status',
    'age',
    'path:directory',
    'filterDirectories'
  ]
  mode: 'running'
  age: 'month' # faster initialization of page
  path: null
  filterDirectories: true
  terms: ''
  poly:
    Ember.computed ->
      @get('controllers.directories').findPolyByPath( @get('path') )
    .property('path', 'controllers.directories.@each')
  directoriesBinding: 'poly.alternatives'

  # when poly has only one alternative or a the directory controller is active
  directory:
    Ember.computed (key, value)->
      if dir = @get('controllers.directory.model')
        return dir

      if dirs = @get('directories') # by setting path through query params
        if dirs.get('length') == 1
          dirs.get('firstObject')
        else
    .property('directories.@each', 'controllers.directory.model')

  detailsRouteActive: false
  detailsExtended: Ember.computed.alias('detailsRouteActive')

  polyDidChange: (->
    if dirs = @get('poly.alternatives') # by setting path through query params
      ctrl = @get('controllers.directory')
      if dirs.get('length') == 1
        dir = dirs.get('firstObject')
        ctrl.set('model', dir)
      else
        ctrl.set('model', false) unless dirs.indexOf( ctrl.get('model') ) >= 0
  ).observes('poly')

  # TODO i18n
  # human readable current age
  describedAge:
    Ember.computed ->
      if @get('age') == 'all'
        "All since ever"
      else
        "in this " + @get('age')
    .property('age')
