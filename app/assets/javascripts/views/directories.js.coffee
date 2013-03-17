Cataract.LinkToDirectory = Ember.View.extend
  template: Ember.Handlebars.compile '{{#linkTo directory view.content}}{{view.content.name}}{{/linkTo}}'

Cataract.DirectoriesTable = Cataract.Table.extend
  classNames: 'table table-striped directories'.w()
  columns: [
    { name: "Disk", property: 'disk.name' },
    { name: "Name", viewClass: Cataract.LinkToDirectory }
  ]

Cataract.DirectoryNavListView = Ember.View.extend
  directories: []
  templateName: 'directory/nav_list'
  tagName: 'ul'
  classNames: "nav nav-list directories".w()

Cataract.DirectoryNavItemView = Ember.View.extend
  directory: null
  templateName: 'directory/nav_item'
  tagName: 'li'
  classNameBindings: "cssClass active exists:existing:missing".w()
