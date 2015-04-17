Ember.Handlebars.helper 'ago', (value, options)->
  mom = moment(value)
  long = mom.format('llll')
  short = mom.fromNow()
  return new Ember.Handlebars.SafeString("<span class='ago' title='#{long}'>#{short}</span>")
