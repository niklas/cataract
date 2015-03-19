Ember.Handlebars.helper 'human-kilo-bytes', (value, options)->
  base     = options.base || 1024
  short    = options.short || false
  pow      = options.pow || 0
  decimal  = 1

  i = parseInt(value) * Math.pow(base, pow)

  e = Math.log(i) / Math.log(base) | 0
  mult = if e then "KMGTPEZY"[e - 1] else ''
  unit = if short then '' else (if e then 'iB' else 'Bytes')

  (
    i / Math.pow(base, e)
  ).toFixed(decimal) +
    (if short then '' else ' ') +
    mult +
    unit

