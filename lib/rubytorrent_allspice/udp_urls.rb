# rubytorrent barks if the annoncelist contains only udp URLs (which are
# instances of URI::Generic), so we just skip the check alltogether
class RubyTorrent::MetaInfo

  def initialize_with_generic_url(*a)
    initialize_without_generic_url(*a)
    @s.instance_variable_get('@field')[:announce] = URI::Generic
  end

  alias_method_chain :initialize, :generic_url

  def check
  end

end
