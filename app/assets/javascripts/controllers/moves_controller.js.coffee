Cataract.MovesController = Ember.ArrayController.extend
  moves: Ember.computed.filterBy 'content', 'isNew', false

