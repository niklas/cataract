Cataract.ProgressBarComponent = Ember.Component.extend
  percentage: 0
  hasStripes: false
  isAnimated: false
  breakLabel: 23

  classNames: ['progress']
  style: Ember.computed 'percentage', ->
    "width: #{@get('percentage')}%"
  textStyle: Ember.computed 'isBeginning', ->
    if @get('isBeginning')
      'right: 0.3em; position: absolute;'


  classNameBindings: [
    'isAnimated:active'
    'hasStripes:progress-striped'
  ]

  # The progress bar itself must be big enough to contain the percentage label #d'oh
  isBeginning: Ember.computed 'percentage', 'breakLabel', ->
    @get('percentage') < @get('breakLabel')

