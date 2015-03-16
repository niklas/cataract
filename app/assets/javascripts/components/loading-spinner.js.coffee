# =require 'spin'
# =require 'jquery.spin'
Cataract.LoadingSpinnerComponent = Ember.Component.extend
  classNames: ['loading-spinner']
  didInsertElement: ->
    $(document).ajaxStart => @set 'enabled', true
    $(document).ajaxStop  => @set 'enabled', false

  enabled: false
  isVisibleBinding: 'enabled'
