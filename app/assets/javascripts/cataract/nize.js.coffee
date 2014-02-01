Cataract.Nize = Ember.CollectionView.extend
  classNames: ['nize']
  value: 0
  tagName: 'ul'
  itemViewClass: Ember.View.extend
    classNameBindings: ['tenTwoThe']
    tenTwoThe: Ember.computed(->
      "t#{@get('content')}"
    ).property('content')

  word: Ember.computed(->
    @get('content').join('')
  ).property('content')
  content: Ember.computed(->
    list = Ember.A()
    value = @get('value')
    max = 9
    for pow in [7..0]
      s = Math.pow(10, pow)
      while value >= s
        value -= s
        list.pushObject pow.toString()
        return list if list.length == max
    # fill up with _
    for n in [list.length+1..max]
      list.pushObject '_'
    list
  ).property('value')

