Cataract.QueueItemView = Ember.View.extend
  template: Ember.Handlebars.compile '<a href="#">{{view.content.title}}</a>'

Cataract.QueueView = Ember.CollectionView.extend
  tagName: 'ul'
  classNames: 'dropdown-menu'.w()
  itemViewClass: Cataract.QueueItemView

