require 'xmlrpc/client'
require 'xmlrpc/xmlrpcs'
require 'socket'
require 'scgi/wrapped_socket'

# This class presents an XMLXPC-Interface to rtorrent, a fast bittorrent client.
# You don't need a webserver, because it uses local UNIX domain socket for XMLRPC
# thanks to Dario Meloni's gem xmlrpcs

class RTorrent < XMLRPC::ClientS
  class Exception < RuntimeError; end
  class NotReachable < Exception; end
  class NoRPCMethod < Exception; end

  SCGIPath = '/RPC2'

  def new_socket(socket_path, async)
    #UNIXSocket.new(info.to_path)
    SCGI::WrappedSocket.new( UNIXSocket.new(socket_path.to_path), SCGIPath )
  end

  def old_call *a 
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
    @remote_methods ||= call 'system.listMethods'
  end

  def remote_respond_to?(meth)
    remote_methods.include? meth.to_s
  end

  def attrib_for_torrent what, torrent
    hsh = torrent.info_hash rescue nil
    raise TorrentHasNoInfoHash unless hsh
    meth = "get_d_#{what}"
    raise NoRPCMethod, "no such rpc method: #{meth}" unless @remote_methods.include? meth
    call meth, hsh
  end

  def old_method_missing method, *args
    method = method.to_s
    magic_method = "get_#{method}" # just getters for now
    if @remote_methods.include? method
      call method, *args
    elsif @remote_methods.include? magic_method
      call magic_method, *args
    else
      raise NoRPCMethod, "no such rpc method: #{method} or #{magic_method}"
    end
  end

  def running?
    !remote_methods.empty? # initialize will fail earlier
  end
end
