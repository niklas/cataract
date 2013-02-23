Cataract.LinkToCreateDirectory = Ember.View.extend
  template: Ember.Handlebars.compile '<a href="#" {{action createDirectory view.content target="view"}} class="btn btn-warning btn-mini">Import</a>'
  createDirectory: (detected) ->
    detected.createDirectory().get('transaction').commit()

Cataract.DetectedDirectoriesTable = Cataract.Table.extend
  classNames: 'table table-striped new directories'.w()
  columns: [
    { name: "Name", property: 'name' }
    { name: "Action", viewClass: Cataract.LinkToCreateDirectory, class: 'action' }
  ]

