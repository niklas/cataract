window.fileSize = (i, opts={}) ->
  base = opts.base || 1024
  short = opts.short || false

  e = Math.log(i) / Math.log(base) | 0
  mult = if e then "KMGTPEZY"[e - 1] else ''
  unit = if short then '' else (if e then 'iB' else 'Bytes')

  (
    i / Math.pow(base, e)
  ).toFixed(2) +
    (if short then '' else ' ') +
    mult +
    unit
