require 'xmlrpc/client'
require 'xmlrpc/xmlrpcs'
require 'socket'
require 'scgi/wrapped_socket'
require 'transfer'

class Torrent
  class NotRunning < ActiveRecord::RecordInvalid; end

  temporary_predicate :start_automatically
  after_save :start!, :if => :start_automatically?

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
  #alias_method_chain :method_missing, :xml_rpc

  def self.remote
    @remote ||= RTorrent.new rtorrent_socket_path
  end

  def self.reset_remote!
    @remote = nil
  end

  def transfer
    @transfer ||= Transfer.new self
  end

  def remote
    self.class.remote
  end

  def self.rtorrent_socket_path
    Rails.root/'tmp'/'rtorrent.socket'
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
    remote.set_directory self, content_directory.full_path
  end



  # This Class represents the glue between 
  # the ActiveRecord Model Torrent and the 
  # XMLRPC Client/RTorrent wrapper

  class RTorrent < XMLRPC::ClientS
    class Offline < ::RuntimeError; end
    class Unreachable < Offline; end
    class CouldNotFindInfoHash < ::ArgumentError; end
    class NoRemoteMethodError < ::NoMethodError; end

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
    rescue Errno::ECONNREFUSED => e
      raise Unreachable, e.message
    rescue Errno::ENOENT => e
      raise Unreachable, e.message
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

    def self.define_attribute(name, &block)
      mapped = map_method_name(name)
      define_method name do |torrent|
        block.call call_with_torrent(mapped, torrent)
      end
      Torrent.delegate name, to: :transfer
    end

    def self.reader(name)
      Transfer.class_eval do
        serializable_attr_accessor name
      end
      define_attribute name do |value|
        value
      end
    end

    def self.predicate(name)
      internal_name = name.to_s.sub(/\?$/,'')
      Transfer.class_eval do
        attr_accessor internal_name
        alias_method name, internal_name
      end
      define_attribute name do |value|
        value.to_i > 0
      end
    end

    def self.bang(name)
      mapped = map_method_name(name)
      define_method name do |torrent|
        call_with_torrent(mapped, torrent)
      end
      Torrent.delegate name, to: :transfer
    end


    readers :name
    readers :size_bytes, :completed_bytes
    readers :up_rate, :down_rate
    predicate :active?
    readers :up_total, :down_total, :message, :state
    predicate :open?
    bangs :start!, :stop!, :close!, :erase!

    # load the path into rtorrent
    def load!(path)
      raise("cannot load torrent, path not readable: #{path}") unless File.readable?(path)
      if remote_respond_to?('load.normal') # 0.9+
        call 'load.normal', '', path.to_s
      else
        call 'load', path.to_s
      end
    end

    def start_and_wait!(torrent)
      start!(torrent)
      wait_until 20 do
        active?(torrent)
      end
    end

    def stop_and_wait!(torrent)
      stop!(torrent)
      wait_until 20 do
        !active?(torrent)
      end
    end

    def wait_until(duration=5, pause=0.1)
      Timeout.timeout(duration) do
        while sleep(pause)
          return if yield
        end
      end
    end


    # FIXME providing a view name raises: XMLRPC::FaultException: Unsupported target type found.
    #       (update rtorrent to 0.9?)
    def download_list(view='main')
      call 'download_list'
    end

    def set_directory(torrent, path)
      call_with_torrent one_of('d.set_directory', 'd.directory.set'), torrent, path.to_s
    end

    # sets the specified fields on the given torrents' transfer(s)
    def apply(torrents, fields)
      by_hash = torrents.group_by(&:info_hash)

      all(*fields).each do |remote|
        if torrent = torrents.find { |t| t.info_hash == remote[:hash] }
          torrent.transfer.update( remote )
        end
      end
    end

    def for_info_hash(info_hash)
      torrents.find { |h| h[:hash] == info_hash }
    end

    def all(*fields)
      multicall(*fields)
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

    def multicall(*remote_fields)
      mapping = build_multicall_mapping *remote_fields
      call(one_of('d.multicall', 'd.multicall2'), '', *mapping.values).map do |it|
        {}.tap do |h|
          mapping.keys.each_with_index do |meth,i|
            h[meth] = it[i]
          end
        end
      end
    end
    # give a list of rubiesque fields, get back hash, mapping them to multicall
    # string. Always includes the torrrent's hash
    def build_multicall_mapping(*fields)
      (fields << :hash).each_with_object({}) do |field, mapping|
        unless field.to_s.ends_with?('!')
          mapping[field] = "#{self.class.map_method_name(field)}="
        end
      end
    end

    # rtorrent introduced a major method name change. This is our try to
    # support both generations
    def one_of(*candidates)
      candidates.find do |c|
        remote_respond_to?(c)
      end || raise(NoRemoteMethodError, "could not find any of #{candidates.join(',')} in #{remote_methods.count} methods")
    end
  end
end
