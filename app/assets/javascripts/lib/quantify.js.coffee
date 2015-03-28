quantify = (bytes, options)->
  options ||= {}
  base     = options.base || 1024
  pow      = options.pow || 0

  i = parseInt(bytes) * Math.pow(base, pow)
  e = Math.log(i) / Math.log(base) | 0
  val = i / Math.pow(base, e)

  {
    val:    val
    factor: if e then "KMGTPEZY"[e - 1] else ''
  }





window.quantify = quantify
