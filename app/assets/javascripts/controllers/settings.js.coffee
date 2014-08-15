Cataract.SettingsController = Ember.ObjectController.extend
  needs: ['directories']

  directoriesBinding: 'controllers.directories.directories'
  isDisabled:
    Ember.computed ->
      unless @get('content.isKindofDirty')
        'disabled'
      else
        null
    .property('content.isKindofDirty')
