attr = DS.attr

Cataract.Move = DS.Model.extend
  torrentId: attr('number')
  torrent: DS.belongsTo('torrent', key: 'torrentId')
  title: attr('string')
  targetDiskId: attr('number')
  targetDisk: DS.belongsTo('disk')
  targetDirectoryId: attr('number')
  targetDirectory: DS.belongsTo('directory', key: 'targetDirectoryId')
