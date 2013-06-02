# =require 'spin'
# =require 'jquery.spin'
Cataract.Spinner = Ember.View.extend
  classNames: ['spincontainer']
  didInsertElement: ->
    $(document).ajaxStop  => @disable()
    $(document).ajaxStart => @enable()
    @enable()

  message: 'please wait...'

  enable: ->
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
    @$().spin(false)

  template: Ember.Handlebars.compile "{{message}}"
