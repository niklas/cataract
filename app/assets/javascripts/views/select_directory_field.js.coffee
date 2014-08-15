Cataract.SelectDirectoryField = Ember.Select.extend
  optionLabelPath: 'content.name'
  optionValuePath: 'content.id'

  didInsertElement: ->
    # FIXME refresh association bindings, else no value is bound, even with defaults
    @$(':input').change()
    @_super()
