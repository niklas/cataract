Cataract.LinkToDirectory = Ember.View.extend
  template: Ember.Handlebars.compile '{{#linkTo directory view.content}}{{view.content.name}}{{/linkTo}}'

Cataract.DirectoriesTable = Cataract.Table.extend
  classNames: 'table table-striped directories'.w()
  columns: [
    { name: "Disk", property: 'disk.name' },
    { name: "Name", viewClass: Cataract.LinkToDirectory }
  ]
