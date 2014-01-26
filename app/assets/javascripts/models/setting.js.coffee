attr = DS.attr
Cataract.Setting = DS.Model.extend

  # OPTIMIZE must simulate association because there is no reflecting assoc in Cataract.Directory ?
  incomingDirectory: DS.belongsTo('directory')
  disableSignup: attr 'boolean'
  bookmarkLink: attr 'string'


Cataract.Setting.reopenClass
  url: 'setting' # Emu serialization key
