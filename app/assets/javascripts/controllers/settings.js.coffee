Cataract.SettingsController = Ember.ObjectController.extend
  needs: ['directories']

  directoriesBinding: 'controllers.directories.directories'
  disableSave: Ember.computed.not 'content.isKindofDirty'
