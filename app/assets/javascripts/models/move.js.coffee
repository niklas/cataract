Cataract.Move = Emu.Model.extend
  torrentId: Emu.field('number')
  torrent: Emu.belongsTo('Cataract.Torrent', key: 'torrentId')
  title: Emu.field('string')
  targetDiskId: Emu.field('number')
  targetDisk: Emu.belongsTo('Cataract.Disk', key: 'targetDiskId')
  targetDirectoryId: Emu.field('number')
  targetDirectory: Emu.belongsTo('Cataract.Directory', key: 'targetDirectoryId')

Cataract.Move.reopenClass
  url: 'move' # Emu create param
