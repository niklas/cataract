require "xmlrpc/client"
# This class presents an XMLXPC-Interface to rtorrent, a fast bittorrent client.
# You have to setup your webserver like described in 
# http://libtorrent.rakshasa.no/wiki/RTorrentXMLRPCGuide
class RTorrent
  class Exception < RuntimeError; end
  class NotReachable < Exception; end
  class NoRPCMethod < Exception; end

  def initialize
    @rpc = XMLRPC::Client.new '127.0.0.1', '/rtorrentrpc', 80
  end

  def call *a 
    tries = 1
    begin
      tries += 1
      @rpc.call *a
    rescue RuntimeError => e
      case e.message
      when /HTTP-Error: 500 Internal Server Error/
        raise NotReachable, 'Error 500 in the HTTP gateway - maybe rtorrent is not running?'
      when /HTTP-Error: 404 Not Found/
        raise NotReachable, 'Error 404 in the HTTP gateway - maybe rtorrent is not running?'
      else
        raise e
      end
    rescue XMLRPC::FaultException => e
      if e.message =~ /Could not find info-hash./
        raise TorrentNotRunning, 'this torrent is not being downloaded currently'
      else
        raise Exception, e.message
      end
    rescue Errno::EPIPE
      initialize
      retry if tries < 5
    end
  end

  def remote_methods
    @methods ||= call 'system.listMethods'
  end

  def remote_respond_to?(meth)
    remote_methods.include? meth.to_s
  end

  def attrib_for_torrent what, torrent
    hsh = torrent.info_hash rescue nil
    raise TorrentHasNoInfoHash unless hsh
    meth = "get_d_#{what}"
    raise NoRPCMethod, "no such rpc method: #{meth}" unless @methods.include? meth
    call meth, hsh
  end

  def method_missing method, *args
    method = method.to_s
    magic_method = "get_#{method}" # just getters for now
    if @methods.include? method
      call method, *args
    elsif @methods.include? magic_method
      call magic_method, *args
    else
      raise NoRPCMethod, "no such rpc method: #{method} or #{magic_method}"
    end
  end

  def running?
    !remote_methods.empty? # initialize will fail earlier
  end
end

