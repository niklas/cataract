Cataract.Table = Ember.ContainerView.extend
  tagName: 'table'
  childViews: ['thead', 'tbody']
  columns: []
  thead: Ember.ContainerView.create
    tagName: 'tr'
    childViews: ['header']
    header: Ember.CollectionView.create
      tagName: 'tr'
      contentBinding: 'parentView.parentView.columns'
      itemViewClass: Ember.View.extend
        tagName: 'th'
        template: Ember.Handlebars.compile '{{view.content.name}}'
  tbody: Ember.CollectionView.create
    tagName: 'tbody'
    contentBinding: 'parentView.content'
    itemViewClass: Ember.ContainerView.extend # row
      tagName: 'tr'
      childViews: ['cells']
      columnsBinding: 'parentView.parentView.columns'
      values: (->
        content = @get('content')
        @get('columns').map (column) -> content.get(column.property)
      ).property('content')
      cells: Ember.CollectionView.extend
        contentBinding: 'parentView.values'
        itemViewClass: Ember.View.extend
          tagName: 'td'
          template: Ember.Handlebars.compile '{{view.content}}'

Cataract.DirectoriesTable = Cataract.Table.extend
  classNames: 'table table-striped directories'.w()
  columns: [
    { name: "Disk", property: 'disk.name' }
    { name: "Name", property: 'name' }
  ]
