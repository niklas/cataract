require 'maulwurf'
class TorrentFetcher < Maulwurf
  page %r~http://torrentz.eu/\w{40}~ => follow('kickass.to')
end
