Cataract.EditDirectoryModal = Bootstrap.ModalPane.extend
  directory: null

  headingBinding: 'directory.name'
  bodyViewClass: Cataract.EditDirectoryView
  primary: 'Save'
  secondary: 'Cancel'
  showBackdrop: true
  callback: (opts) ->
    directory = @get('directory')
    if opts.primary
      directory.get('transaction').commit()
    else
      directory.get('transaction').rollback()
    if back = @get('back')
      Cataract.Router.router.transitionTo( back... )

