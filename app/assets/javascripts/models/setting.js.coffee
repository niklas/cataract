attr = DS.attr
Cataract.Setting = DS.Model.extend

  # must simulate association because there is no reflecting assoc in Cataract.Directory
  incomingDirectoryId: attr 'number'
  incomingDirectory: DS.belongsTo('directory', key: 'incomingDirectoryId')
  disableSignup: attr 'boolean'

Cataract.Setting.reopenClass
  url: 'setting' # Emu serialization key
