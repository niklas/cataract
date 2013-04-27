Cataract.Setting = Emu.Model.extend

  # must simulate association because there is no reflecting assoc in Cataract.Directory
  incomingDirectoryId: Emu.field 'number'
  incomingDirectory: Ember.computed ->
    if did = @get('incomingDirectoryId')
      Cataract.Directory.find did
    else
      null
  .property('incomingDirectoryId')
  disableSignup: Emu.field 'boolean'

