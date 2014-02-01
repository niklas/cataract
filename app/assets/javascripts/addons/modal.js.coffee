Cataract.ModalPane = Bootstrap.ModalPane.extend
  showBackdrop: true
  ok: Ember.K
  cancel: Ember.K
  done: Ember.K
  backRoute: null
  callback: (opts) ->
    if opts.primary
      @get('ok').bind(@)(opts)
    else
      @get('cancel').bind(@)(opts)
    if back = @get('backRoute')
      Cataract.Router.router.transitionTo( back... )
    if done = @get('done')
      done.call(@)
    true
