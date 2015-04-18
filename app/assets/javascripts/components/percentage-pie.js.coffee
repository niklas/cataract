Cataract.PercentagePieComponent = Ember.Component.extend
  tagName: 'div'
  classNames: [
    'pie'
  ]

  value: 0
  total: 1

  percentage: Ember.computed 'value', 'total', ->
    100 * @get('value') / @get('total')

  moreThanHalf: Ember.computed 'percentage', ->
    @get('percentage') > 50

  percent: Ember.computed 'percentage', ->
    "#{ Math.round(@get 'percentage') }%"

  style: Ember.computed 'percentage', 'elementId', ->
    me = @get 'elementId'
    deg = Math.round( @get('percentage') * 360 / 100 )
    css = """
      ##{me} .slice:BEFORE {
        transform: rotate(#{deg}deg);
      }
    """
    "<style>#{css}</style>"
