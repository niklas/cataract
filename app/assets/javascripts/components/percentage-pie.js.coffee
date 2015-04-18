Cataract.PercentagePieComponent = Ember.Component.extend
  tagName: 'div'
  classNames: [
    'pie'
  ]

  value: 0
  total: 1

  percentage: Ember.computed 'value', 'total', ->
    100 * @get('value') / @get('total')

  style: Ember.computed 'percentage', 'elementId', ->
    me = @get 'elementId'
    deg = Math.round( @get('percentage') * 360 / 100 )
    css = if deg <= 180
      """
        ##{me} .slice {
          transform: rotate(#{deg}deg);
        }
      """
    else
      """
        ##{me} .slice {
          transform: rotate(180deg);
        }
        ##{me} .slice .p {
          transform: rotate(#{deg - 180}deg);
        }
      """
    "<style>#{css}</style>"
