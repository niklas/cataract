Cataract.Setting = Emu.Model.extend

  # must simulate association because there is no reflecting assoc in Cataract.Directory
  incomingDirectoryId: Emu.field 'number'
  incomingDirectory: Emu.belongsTo('Cataract.Directory', key: 'incomingDirectoryId')
  disableSignup: Emu.field 'boolean'

Cataract.Setting.reopenClass
  url: 'setting' # Emu serialization key
