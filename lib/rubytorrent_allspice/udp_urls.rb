# rubytorrent barks if the annoncelist contains only udp URLs (which are
# instances of URI::Generic), so we loosen the checks a bit
class RubyTorrent::MetaInfo

  def uri_class
    URI::Generic
  end

end
