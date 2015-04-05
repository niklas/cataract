Cataract.DropZoneComponent = Ember.Component.extend
  elementId: 'dropzone'
  classNameBindings: ['hovered', 'inviting']

  hovered: false
  inviting: false

  drop: (event) ->
    event.preventDefault()
    @set 'hovered', false
    @set 'inviting', false
    @sendAction 'action', file for file in event.dataTransfer.files
    false


  dragOver: (e) ->
    e.preventDefault()
    unless @get('hovered')
      @set 'hovered', true

  dragLeave: (e) ->
    e.preventDefault()
    @set 'hovered', false


