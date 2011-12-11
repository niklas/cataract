require 'xmlrpc/client'
require 'xmlrpc/xmlrpcs'
require 'socket'
require 'scgi/wrapped_socket'

class Torrent
  class NotRunning < ActiveRecord::RecordInvalid; end

  def method_missing_with_xml_rpc(meth, *args, &blk)
    if remote.respond_to?(meth)
      remote.public_send meth, self, *args, &blk
    else
      method_missing_without_xml_rpc meth, *args, &blk
    end
  rescue NotRunning => e
    finally_stop! unless archived?
    raise e
  rescue HasNoInfoHash => e
    finally_stop!
    return
  end
  alias_method_chain :method_missing, :xml_rpc

  def self.remote
    @remote ||= RTorrent.new rtorrent_socket_path
  end

  def self.reset_remote!
    @remote = nil
  end

  def remote
    self.class.remote
  end

  def self.rtorrent_socket_path
    Rails.root/'tmp'/'sockets'/'rtorrent'
  end

  def load!
    remote.load! self
  end


  # This Class represents the glue between 
  # the ActiveRecord Model Torrent and the 
  # XMLRPC Client/RTorrent wrapper

  class RTorrent < XMLRPC::ClientS
    Methods = [:up_rate, :up_total, :down_rate, :down_total, :size_bytes, :message, :completed_bytes, :open?, :active?]

    class << self
      def offline!
        @offline = true
      end
      def offline?
        @offline == true
      end
      def online!
        @offline = nil
      end

    end

    class NoRemoteMethodError < ::NoMethodError; end

    SCGIPath = '/RPC2'

    def new_socket(socket_path, async)
      #UNIXSocket.new(info.to_path)
      SCGI::WrappedSocket.new( UNIXSocket.new(socket_path.to_path), SCGIPath )
    end

    def remote_methods
      @remote_methods ||= call 'system.listMethods'
    end

    def remote_respond_to?(meth)
      remote_methods.include? meth.to_s
    end

    def running?
      !remote_methods.empty? # initialize will fail earlier
    end

    def call(*a, &block)
      unless self.class.offline?
        super
      else
        Rails.logger.debug { "cannot call RTorrent because it was switched offline" }
      end
    end

    def respond_to_missing?(meth, include_private)
      Methods.include?(meth.to_sym) || super
    end

    def method_missing(meth, *args, &block)
      if respond_to_missing?(meth, false)
        mapped = map_method_name(meth)
        result = call_with_torrent(mapped, *args, &block)
        if meth =~ /\?$/ # cast booleans
          result > 0
        else
          result
        end
      else
        super
      end
    end

    # load the path into rtorrent
    def load!(torrent)
      call 'load', torrent.path.to_s
    end

    # FIXME providing a view name raises: XMLRPC::FaultException: Unsupported target type found.
    #       (update rtorrent to 0.9?)
    def download_list(view='main')
      call 'download_list'
    end


    private
    def call_with_torrent(meth, torrent, *args, &blk)
      hash = torrent.info_hash rescue nil
      raise Torrent::HasNoInfoHash if hash.blank?
      call meth, hash, *args, &blk
    end

    def map_method_name(meth)
      case meth
      when /^(.+)=$/    # setters
        "d.set_#{$1}"
      when /^(.+)!$/    # commands (for torrent)
        "d.#{$1}"
      when /^(.+)\?$/   # booleans? (for torrent)
        "d.is_#{$1}"
      else              # getters
        "d.get_#{meth}"
      end
    end
  end
end
