Cataract.Move = DS.Model.extend
  torrent: DS.belongsTo('Cataract.Torrent')
  title: DS.attr('string')
  targetDisk: DS.belongsTo('Cataract.Disk')
  targetDirectory: DS.belongsTo('Cataract.Directory')
