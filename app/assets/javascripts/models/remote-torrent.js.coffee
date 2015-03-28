Cataract.RemoteTorrent = DS.Model.extend
  title: DS.attr 'string'
  uri: DS.attr 'string'
  directory: DS.belongsTo 'directory'
