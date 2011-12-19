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

  # rTorrent deletes the torrent file if removing a tied torrent, so we will
  # only add a copy of our torrent to rtorrent. For this we will use
  # #session_path
  def session_path
    path.to_path + '.running'
  end

  def load!
    FileUtils.cp path, session_path
    remote.load! session_path
    remote.set_directory self, content_directory.path
  end


  # This Class represents the glue between 
  # the ActiveRecord Model Torrent and the 
  # XMLRPC Client/RTorrent wrapper

  class RTorrent < XMLRPC::ClientS
    Methods = [:up_rate, :up_total, :down_rate, :down_total, :size_bytes, :message, :completed_bytes, :open?, :active?, :start!]

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
          result.to_i > 0
        else
          result
        end
      else
        super
      end
    end

    # load the path into rtorrent
    def load!(path)
      call 'load', path.to_s
    end

    # FIXME providing a view name raises: XMLRPC::FaultException: Unsupported target type found.
    #       (update rtorrent to 0.9?)
    def download_list(view='main')
      call 'download_list'
    end

    def set_directory(torrent, path)
      call_with_torrent 'd.set_directory', torrent, path.to_s
    end

    def torrents
      multicall({
        :name             => "d.get_name=",
        :size_bytes       => "d.get_size_bytes=",
        :completed_bytes  => "d.get_completed_bytes=",
        #:up_rate          => "d.get_up_rate=",
        #:down_rate        => "d.get_down_rate=",
        #:size_files       => "d.get_size_files=",
        #:tracker_size     => "d.get_tracker_size=",
        #:chunk_size       => "d.get_chunk_size=",
        #:size_chunks      => "d.get_size_chunks=",
        #:completed_chunks => "d.get_completed_chunks=",
        #:ratio            => "d.get_ratio=",
        :active           => "d.is_active=",
        #:complete         => "d.get_complete=",
        #:priority         => "d.get_priority=",
        :hash             => "d.get_hash="
      })
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

    def multicall(mapping)
      call('d.multicall', '', *mapping.values).map do |it|
        {}.tap do |h|
          mapping.keys.each_with_index do |meth,i|
            h[meth] = it[i]
          end
        end
      end
    end
  end
end
