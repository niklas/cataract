attr = DS.attr

Cataract.Move = DS.Model.extend
  torrent: DS.belongsTo('torrent')
  title: attr('string')
  targetDisk: DS.belongsTo('disk')
  targetDirectory: DS.belongsTo('directory')
  targetPolyDirectory: Cataract.PolyDiskDirectory.attr('targetDirectory')
