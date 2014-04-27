Cataract.ModalPane = Bootstrap.ModalPane.extend
  showBackdrop: true
  ok: Ember.K
  cancel: Ember.K
  done: Ember.K
  backRoute: null
  callback: (opts) ->
    reaction = if opts.primary
                 @get('ok').bind(@)(opts)
               else
                 @get('cancel').bind(@)(opts)

    # dummy promise for the bad code
    unless reaction.then
      reaction = new Ember.RSVP.Promise(  (resolve,_)-> resolve() )

    reaction.then =>
      if back = @get('backRoute')
        Cataract.Router.router.transitionTo( back... )
      if done = @get('done')
        done.call(@)
