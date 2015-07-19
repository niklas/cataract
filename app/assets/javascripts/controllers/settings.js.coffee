Cataract.SettingsController = Ember.Controller.extend
  needs: ['directories']

  directoriesBinding: 'controllers.directories.directories'
  disableSave: Ember.computed.not 'content.isKindofDirty'
