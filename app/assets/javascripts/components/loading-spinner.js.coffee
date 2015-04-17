Cataract.LoadingSpinnerComponent = Ember.Component.extend
  classNames: ['loading-spinner']
  listen: true
  didInsertElement: ->
    if @get('listen')
      $(document).ajaxStart => @set 'enabled', true
      $(document).ajaxStop  => @set 'enabled', false

  enabled: false
  isVisibleBinding: 'enabled'
