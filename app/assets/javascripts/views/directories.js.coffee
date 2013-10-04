Cataract.LinkToDirectory = Ember.View.extend
  oldtemplate: Ember.Handlebars.compile "{{#link-to 'directory' view.content}}{{view.content.name}}{{/link-to}}"
  template: Ember.Handlebars.compile "{{view.content.name}}"

Cataract.DirectoriesTable = Cataract.Table.extend
  classNames: 'table table-striped directories'.w()
  columns: [
    { name: "Disk", property: 'disk.name' },
    { name: "Name", viewClass: Cataract.LinkToDirectory }
  ]

Cataract.DirectoryNavListView = Ember.View.extend
  content: []
  templateName: 'directory/nav_list'
  tagName: 'ul'
  classNames: "nav nav-list directories".w()

Cataract.DirectoryNavItemView = Ember.View.extend
  templateName: 'directory/nav_item'
  tagName: 'li'
  classNameBindings: ":directory active exists:existing:missing".w()
  existsBinding: 'content.exists'
