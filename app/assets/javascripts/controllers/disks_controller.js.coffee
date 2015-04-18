Cataract.DisksController = Ember.ArrayController.extend
  reactToModelChanges: (->
    @get('serverEvents.source').addModelEventListener 'disk'
  ).on('init')

