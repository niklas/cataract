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
  templateName: 'directory/nav_item'
  tagName: 'li'
  classNameBindings: ":directory active exists:existing:missing".w()
  existsBinding: 'content.exists'
