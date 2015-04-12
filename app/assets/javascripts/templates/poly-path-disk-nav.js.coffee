c = Ember.computed
Cataract.PolyPathDiskNavComponent = Ember.Component.extend
  content:    null  # poly
  targetRoute: 'directory'
  classNames: [
    'disk-nav'
    'row'
  ]

  alternatives: c.alias 'content.alternatives'
  firstAlternative: c.alias 'alternatives.firstObject'
  disks:        c.mapProperty 'alternatives', 'disk'
  allDiskSize:  c.mapProperty 'disks', 'size'
  allDiskFree:  c.mapProperty 'disks', 'free'
  sumDiskSize:  c.sum 'allDiskSize'
  sumDiskFree:  c.sum 'allDiskFree'

  noDisk: c 'allDiskSize', 'allDiskFree', ->
    Ember.Object.create
      name: '[All]'
      size:  @get('sumDiskSize')
      free:  @get('sumDiskFree')
      isMounted: true
      id:    undefined
