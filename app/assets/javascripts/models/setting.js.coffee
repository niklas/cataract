Cataract.Setting = DS.Model.extend
  incomingDirectory: DS.belongsTo 'Cataract.Directory'
  disableSignup: DS.attr 'boolean'

