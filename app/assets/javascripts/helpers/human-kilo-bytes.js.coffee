Ember.Handlebars.helper 'human-kilo-bytes', (value, meta)->
  options  = meta?.hash || {}
  short    = options.short || false
  decimals = options.decimals || 1
  base     = options.base || 1024

  quant = quantify value, options

  unit = if short then 'B' else 'Bytes'
  unit = 'i' + unit if base is 1024

  val = if quant.val > 0 then quant.val.toFixed(decimals) else '???'
  val +
    (if short then '' else ' ') +
    quant.factor +
    unit
