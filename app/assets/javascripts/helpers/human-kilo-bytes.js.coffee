Ember.Handlebars.helper 'human-kilo-bytes', (value, options)->
  short    = options.short || false
  decimals = options.decimals || 1

  quant = quantify value, options

  unit = if short then 'iB' else 'Bytes'

  quant.val.toFixed(decimals) +
    (if short then '' else ' ') +
    quant.factor +
    unit

