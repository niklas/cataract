# =require 'spin'
# =require 'jquery.spin'
Cataract.Spinner = Ember.View.extend
  classNames: ['spincontainer']
  didInsertElement: ->
    $(document).ajaxStop  => @disable()
    $(document).ajaxStart => @enable()
    @enable()

  enabled: false

  message: 'please wait...'

  enable: ->
    return if @get('enabled')
    @set('enabled', true)
    sib = @$().siblings('a')
    @$().spin(
      lines: 8
      length: 4
      width: 3
      radius: 5
      left: sib.height()
      top: sib.height() / 2
    )

  disable: ->
    @set('enabled', false)
    @$().spin(false)

  template: Ember.Handlebars.compile "{{message}}"
