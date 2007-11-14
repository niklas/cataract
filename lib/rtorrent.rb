require "xmlrpc/client"
# This class presents an XMLXPC-Interface to rtorrent, a fast bittorrent client.
# You have to setup your webserver like described in 
# http://libtorrent.rakshasa.no/wiki/RTorrentXMLRPCGuide
class RTorrent
  def initialize
    @rpc = XMLRPC::Client.new '127.0.0.1', '/rtorrentrpc', 80
    @methods = call 'system.listMethods'
  end

  def call *a 
    begin
      @rpc.call *a
    rescue RuntimeError => e
      if e.message =~ /HTTP-Error: 500 Internal Server Error/
        raise RTorrentException, 'Error 500 in the HTTP gateway - maybe rtorrent is not running?'
      else
        raise e
      end
    rescue XMLRPC::FaultException => e
      if e.message =~ /Could not find info-hash./
        raise TorrentNotRunning, 'this torrent is not being downloaded currently'
      else
        raise RTorrentException, e.message
      end
    end
  end

  def remote_methods
    @methods
  end

  def attrib_for_torrent what, torrent
    hsh = torrent.info_hash rescue nil
    raise TorrentHasNoInfoHash unless hsh
    meth = "get_d_#{what}"
    raise RTorrentException, "no such rpc method: #{meth}" unless @methods.include? meth
    call meth, hsh
  end

  def method_missing method, *args
    if @methods.include? method
      call method, *args
    else
      raise RTorrentException, "no such rpc method: #{method}"
    end
  end
end

class RTorrentException < Exception; end
class TorrentHasNoInfoHash < RTorrentException; end
class TorrentNotRunning < RTorrentException; end
class RTorrentNotReachable < RTorrentException; end
