Cataract.Router.map ->
  @route 'add', path: '/add'
  @resource 'directory', path: '/directory/:directory_id'
  @route 'disk', path: 'disk/:disk_id'
  @route 'new_directory', path: 'directory/new'
  @route 'settings'
  @route 'running'
  @route 'recent'
  @route 'library', ->
    @resource 'directory', path: 'directory/:directory_id', ->
      @route 'online'
      @route 'detect'
      @route 'children'
    @resource 'disk', path: 'disk/:disk_id'
