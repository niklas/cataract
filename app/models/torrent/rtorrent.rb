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
    class Offline < ::RuntimeError; end
    class CouldNotFindInfoHash < ::ArgumentError; end

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
        raise Offline, "cannot call RTorrent because it was switched offline"
      end
    end

    def self.map_method_name(meth)
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

    def self.readers(*all)
      all.each { |e| reader e }
    end

    def self.bangs(*all)
      all.each { |e| bang e }
    end

    Attributes = Set.new

    Attributes << [:hash, map_method_name(:hash)]

    def self.define_attribute(name, &block)
      mapped = map_method_name(name)
      Attributes << [name, mapped]
      define_method name do |torrent|
        if cached = torrents_by_info_hash[hash_for(torrent)]
          cached[name]
        else
          block.call call_with_torrent(mapped, torrent)
        end
      end
    end

    def self.reader(name)
      define_attribute name do |value|
        value
      end
    end

    def self.predicate(name)
      define_attribute name do |value|
        value.to_i > 0
      end
    end

    def self.bang(name)
      mapped = map_method_name(name)
      define_method name do |torrent|
        call_with_torrent(mapped, torrent)
      end
    end


    readers :name
    readers :size_bytes, :completed_bytes
    readers :up_rate, :down_rate
    predicate :active?
    readers :up_total, :down_total, :message
    predicate :open?
    bangs :start!, :stop!, :close!, :erase!

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
      multicall(torrents_mapping)
    end

    def torrents_by_info_hash
      @torrents_by_info_hash ||= torrents.each.with_object({}) do |t,h|
        h[ t[:hash] ] = t
      end
    end

    def clear_caches!
      @torrents_by_info_hash = nil
    end

    def torrents_mapping
      Attributes.each.with_object({}) do |(acc, int), h|
        unless acc.to_s.ends_with?('!')
          h[acc] = "#{int}="
        end
      end
    end


    private
    def call_with_torrent(meth, torrent, *args, &blk)
      call meth, hash_for(torrent), *args, &blk
    rescue XMLRPC::FaultException => e
      if e.message =~ /Could not find info-hash/
        raise CouldNotFindInfoHash, e.message
      else
        raise e
      end
    end

    def hash_for(torrent)
      hash = torrent.info_hash rescue nil
      raise Torrent::HasNoInfoHash if hash.blank?
      hash
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
