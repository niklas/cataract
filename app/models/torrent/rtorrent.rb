require_dependency 'rtorrent'

class Torrent
  class NotRunning < ActiveRecord::RecordInvalid; end
  MethodsForRTorrent = [:up_rate, :up_total, :down_rate, :down_total, :size_bytes, :message, :completed_bytes, :open?, :active?]

  def method_missing_with_xml_rpc(m, *args, &blk)
    if MethodsForRTorrent.include?(m.to_sym) and remote
      remote.public_send m, *args, &blk
    else
      method_missing_without_xml_rpc m, *args, &blk
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
    @remote ||= RTorrentProxy.new
  end

  def remote
    @remote ||= RTorrentProxy.new(self)
  end


  # This Class represents the glue between 
  # the ActiveRecord Model Torrent and the 
  # XMLRPC Client/RTorrent wrapper

  class RTorrentProxy

    class NoRemoteMethodError < ::NoMethodError; end

    def self.offline!
      @offline = true
    end
    def self.offline?
      @offline == true
    end
    def self.online!
      @offline = nil
    end

    # the XMLRPC interface to the rtorrent process
    def self.remote
      @@rtorrent ||= RTorrent.new
    end

    def self.call(*a, &block)
      unless offline?
        remote.call *a, &blk
      else
        Rails.logger.debug { "cannot call RTorrent because it was switched offline" }
      end
    end

    def remote
      raise "nostubby"
      self.class.remote
    end


    attr_reader :model

    def initialize(model)
      @model = model    # the ActiveRecord::Base
    end

    def method_missing(meth,*args,&blk)
      mapped = map_method_name(meth)
      if remote.remote_respond_to?(mapped)
        result = call_with_model(mapped, *args, &block)
        if meth.ends_with?('?')
          result > 0
        else
          result
        end
      else
        raise NoRemoteMethodError, "RTorrent does not respond to: #{meth}"
      end
    end

    def respond_to?(meth)
      remote.remote_respond_to?( map_method_name(meth) )
    end

    # load the path into rtorrent
    def load(path)
      call_remote 'load', path
    end

    private
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

    def call_with_model(m,*args,&blk)
      hsh = model.info_hash rescue nil
      raise TorrentHasNoInfoHash if hash.blank?
      call_remote m, hsh, *args, &blk
    end

    def call_remote(*a, &blk)
      self.class.call(*a, &block)
    end
  end
end
