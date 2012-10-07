Cataract.Directory = DS.Model.extend
  name: DS.attr('string')
  path: DS.attr('string')
  torrents: DS.hasMany('Cataract.Torrent')
  disk: DS.belongsTo('Cataract.Disk')

Cataract.Directory.reopenClass
  url: 'directory'
