Cataract.ApplicationController = Ember.Controller.extend
  init: ->
    @_super()
    @get('fullSiteTitle') # observer does not fire if value is not used

  needs: ['torrents', 'directories', 'disks', 'directory']

  currentController: null

  fullSiteTitleObserver: ( (sender, key) ->
    $('head title').text(sender.get(key))
  ).observes('fullSiteTitle')

  fullSiteTitle:
    Ember.computed ->
      if sub = @get('currentController.siteTitle')
        [ sub, @get('siteTitle')].join(' - ')
      else
        "loading Cataract"
    .property('currentController.siteTitle')

  siteTitle: 'Cataract'

  # save these here to access from all controllers
  queryParams: [
    'mode:status',
    'age',
    'path:directory'
  ]
  mode: 'recent'
  age: 'month' # faster initialization of page
  path: null
  poly:
    Ember.computed ->
      @get('controllers.directories').findPolyByPath( @get('path') )
    .property('path')
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

  detailsExtended:
    Ember.computed ->
      @get('target.router.currentHandlerInfos.lastObject.handler.isDetailed') ||
        @get('directory')?
    .property('target.router.currentHandlerInfos.lastObject.handler', 'directory')

  polyDidChange: (->
    if dirs = @get('poly.alternatives') # by setting path through query params
      ctrl = @get('controllers.directory')
      if dirs.get('length') == 1
        dir = dirs.get('firstObject')
        ctrl.set('model', dir)
      else
        ctrl.set('model', false) unless dirs.indexOf( ctrl.get('model') ) >= 0
  ).observes('poly')
