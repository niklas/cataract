Cataract.Move = DS.Model.extend
  title: DS.attr('string')
  targetDisk: DS.belongsTo('Cataract.Disk')
  targetDirectory: DS.belongsTo('Cataract.Directory')
