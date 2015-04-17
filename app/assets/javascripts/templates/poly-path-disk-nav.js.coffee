c = Ember.computed
Cataract.PolyPathDiskNavComponent = Ember.Component.extend
  content:    null  # poly
  targetRoute: 'directory'
  classNames: [
    'disk-nav'
    'row'
  ]

  allDiskSize:  c.mapProperty 'content', 'size'
  allDiskFree:  c.mapProperty 'content', 'free'
  sumDiskSize:  c.sum 'allDiskSize'
  sumDiskFree:  c.sum 'allDiskFree'

  noDisk: c 'allDiskSize', 'allDiskFree', ->
    Ember.Object.create
      name: '[All]'
      size:  @get('sumDiskSize')
      free:  @get('sumDiskFree')
      isMounted: true
      id:    undefined