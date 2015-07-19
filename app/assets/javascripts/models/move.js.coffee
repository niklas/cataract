attr = DS.attr

Cataract.Move = DS.Model.extend
  torrent: DS.belongsTo('torrent', async: false)
  title: attr('string')
  targetDisk: DS.belongsTo('disk', async: false)
  targetDirectory: DS.belongsTo('directory', async: false)
  targetPolyDirectory: Cataract.PolyDiskDirectory.attr('targetDirectory')
  done: DS.attr('boolean')
