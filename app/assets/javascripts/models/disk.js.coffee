Cataract.Disk = DS.Model.extend
  name: DS.attr('string')
  isMounted: DS.attr('boolean')
  cssClass: 'disk'
  active: (-> this == Cataract.get('currentDisk') ).property('Cataract.currentDisk')
