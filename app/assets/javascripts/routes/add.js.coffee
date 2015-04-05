Cataract.AddRoute = Ember.Route.extend
  redirect: -> @transitionTo 'running', queryParams: { adding: true }
