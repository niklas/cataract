# rubytorrent barks if the annoncelist contains only udp URLs (which are
# instances of URI::Generic), so we just skip the check alltogether
class RubyTorrent::MetaInfo
  def check
  end
end
