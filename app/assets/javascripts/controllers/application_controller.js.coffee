Cataract.ApplicationController = Ember.Controller.extend
  needs: ['directories']
  init: ->
    @_super()
    @get('fullSiteTitle') # observer does not fire if value is not used

  needs: ['torrents', 'directories', 'disks']

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

  # when poly has only one alternative
  directory:
    Ember.computed (key, value)->
      if dirs = @get('directories') # by setting path through query params
        if dirs.get('length') == 1
          @set 'detailsExtended', true
          dirs.get('firstObject')
        else
          @set 'detailsExtended', false # Side-effect, feels dirty, but we HACK controller hierarchy anyway
    .property('directories.@each')
