Cataract.Directory = DS.Model.extend
  name: DS.attr('string')
  path: DS.attr('string')
  torrents: DS.hasMany('Cataract.Torrent')

Cataract.Directory.reopenClass
  url: 'directory'
