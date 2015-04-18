Cataract.PercentagePieComponent = Ember.Component.extend
  tagName: 'div'
  classNames: [
    'pie'
  ]

  value: 0
  total: 1

  percentage: Ember.computed 'value', 'total', ->
    Math.round(100 * @get('value') / @get('total'))

