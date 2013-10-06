Cataract.EditDirectoryModal = Cataract.ModalPane.extend
  directory: null

  headingBinding: 'directory.name'
  bodyViewClass: Cataract.EditDirectoryView
  primary: 'Save'
  secondary: 'Cancel'
  ok: (opts) ->
    directory = @get('directory')
    directory.save()
  cancel: (opts)->
    directory = @get('directory')
    directory.rollback()
