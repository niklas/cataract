Cataract.MovesController = Ember.ArrayController.extend
  savedMoves: Ember.computed.filterBy 'content', 'isNew', false
  moves:      Ember.computed.filterBy 'savedMoves', 'done', false

  reactToModelChanges: (->
    @get('serverEvents.source').addModelEventListener 'move'
  ).on('init')
