Cataract.ModalPane = Bootstrap.ModalPane.extend
  showBackdrop: true
  ok: Ember.K
  cancel: Ember.K
  backRoute: null
  callback: (opts) ->
    if opts.primary
      @get('ok').bind(@)(opts)
    else
      @get('cancel').bind(@)(opts)
    if back = @get('backRoute')
      Cataract.Router.router.transitionTo( back... )
    true
