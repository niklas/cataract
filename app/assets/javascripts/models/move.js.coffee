Cataract.Move = DS.Model.extend
  targetDisk: DS.belongsTo('Cataract.Disk')
  targetDirectory: DS.belongsTo('Cataract.Directory')
