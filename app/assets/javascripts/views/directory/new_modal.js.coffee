Cataract.NewDirectoryView = Ember.View.extend
  templateName: 'directory/new'
  directoriesBinding: 'parentView.directories'
  disksBinding: 'parentView.disks'

Cataract.NewDirectoryModal = Bootstrap.ModalPane.extend
  directories: Ember.A()
  disks: Ember.A()
  directory: null

  heading: "new Directory"
  bodyViewClass: Cataract.NewDirectoryView
  primary: "Create Directory"
  secondary: "Cancel"
  showBackdrop: true
  callback: (opts) ->
    if opts.primary
      directory = @get('directory')
      directory.get('transaction').commit()
    else
      directory.get('transaction').rollback()


