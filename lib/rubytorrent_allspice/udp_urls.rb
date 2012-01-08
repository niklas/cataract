# rubytorrent barks if the annoncelist contains only udp URLs (which are
# instances of URI::Generic), so we just skip the check alltogether
class RubyTorrent::MetaInfo

  def initialize(*)
    super
    @s.instance_variable_get('@field')[:announce] = URI::Generic
  end

  def check
  end

end
