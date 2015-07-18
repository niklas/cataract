Cataract.QueueItemView = Ember.View.extend
  templateName: 'queue-item'

Cataract.QueueView = Ember.CollectionView.extend
  tagName: 'ul'
  classNames: 'dropdown-menu'.w()
  itemViewClass: Cataract.QueueItemView

