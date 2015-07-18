Cataract.PlainContentView = Ember.View.extend
  templateName: 'plain-content'

Cataract.TableCellView = Ember.ContainerView.extend
  tagName: 'td'
  childViews: ['content']

Cataract.Table = Ember.ContainerView.extend
  tagName: 'table'
  childViews: ['thead', 'tbody']
  thead: null # created on initialization so the instances do not share their childviews
  tbody: null
  columns: []
  init: ->
    @set 'thead', Ember.ContainerView.create
      tagName: 'thead'
      childViews: ['header']
      header: Ember.CollectionView.create
        tagName: 'tr'
        contentBinding: 'parentView.parentView.columns'
        itemViewClass: Ember.View.extend
          tagName: 'th'
          templateName: 'table-header'
    @set 'tbody', Ember.CollectionView.create
      tagName: 'tbody'
      contentBinding: 'parentView.content'
      itemViewClass: Ember.ContainerView.extend # row
        tagName: 'tr'
        childViews: ['cells']
        columnsBinding: 'parentView.parentView.columns'
        values: (->
          content = @get('content')
          @get('columns').map (column) ->
            cls = column.property || column.class || column.name.toLowerCase()
            if column.viewClass
              column.viewClass.create content: content, classNames: cls
            else
              Cataract.PlainContentView.create content: content.get(column.property), classNames: cls
        ).property('content')
        cells: Ember.CollectionView.extend
          contentBinding: 'parentView.values'
          itemViewClass: Cataract.TableCellView
    @_super()


