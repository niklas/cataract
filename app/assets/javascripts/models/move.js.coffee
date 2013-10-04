attr = DS.attr

Cataract.Move = DS.Model.extend
  torrentId: attr('number')
  torrent: attr('torrent', key: 'torrentId')
  title: attr('string')
  targetDiskId: attr('number')
  targetDisk: DS.belongsTo('disk')
  targetDirectoryId: attr('number')
  targetDirectory: DS.belongsTo('directory', key: 'targetDirectoryId')

Cataract.Move.reopenClass
  url: 'move' # Emu create param
