Cataract.Nize = Ember.CollectionView.extend
  classNames: ['nize']
  content: Ember.String.w('7 6 5 4 3 2 1 1 1')
  tagName: 'ul'
  itemViewClass: Ember.View.extend
    classNameBindings: ['tenTwoThe']
    tenTwoThe: Ember.computed(->
      "t#{@get('content')}"
    ).property('content')

