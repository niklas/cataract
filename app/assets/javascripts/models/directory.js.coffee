Cataract.Directory = DS.Model.extend
  name: DS.attr('string')
  path: DS.attr('string')
  torrents: DS.hasMany('Cataract.Torrent')
  disk: DS.belongsTo('Cataract.Disk')
  isExisting: DS.attr('boolean')
  cssClass: 'directory'
  parentId: DS.attr 'number'
  parent: DS.belongsTo('Cataract.Directory')

Cataract.Directory.reopenClass
  url: 'directory'
