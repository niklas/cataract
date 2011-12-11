# This Class represents the glue between 
# the ActiveRecord Model Torrent and the 
# XMLRPC Client/RTorrent wrapper

class RTorrentProxy

  class NoRemoteMethodError < NoMethodError; end

  # the XMLRPC interface to the rtorrent process
  def self.remote
    @@rtorrent ||= RTorrent.new
  end

  # Use this in tests to stub away the remote
  def stub_offline!
    stub(:remote_respond_to?).with(:state).and_return(true)
    stub(:call).with(:state).and_return('<remote-state>')
  end

  def remote
    self.class.remote
  end

  attr_reader :model

  def initialize(model)
    @model = model    # the ActiveRecord::Base
  end

  def method_missing(meth,*args,&blk)
    case meth.to_s
    when /^(.+)=$/    # setters
      m = "d.set_#{$1}"
      if remote.remote_respond_to? m
        return with_model(m, *args, &blk)
      end
    when /^(.+)!$/    # commands (for torrent)
      m = "d.#{$1}"
      if remote.remote_respond_to? m
        return with_model(m, *args, &blk)
      end
    when /^(.+)\?$/    # booleans? (for torrent)
      m = "d.is_#{$1}"
      if remote.remote_respond_to? m
        return with_model(m, *args, &blk).to_i > 0
      end
    else              # normal commands
      if remote.remote_respond_to? meth
        return call_remote(meth, *args, &blk)
      end
                      # getters 
      m = "d.get_#{meth}"
      if remote.remote_respond_to? m
        return with_model(m, *args, &blk)
      end
    end
    raise NoRemoteMethodError, "RTorrent does not respond to: #{meth.to_s}"
  end

  # overload the ruby's #load *shiver* to load the torrent into rtorrent
  def load(path)
    call_remote 'load', path
  end

  private
  def with_model(m,*args,&blk)
    hsh = model.info_hash rescue nil
    raise TorrentHasNoInfoHash unless hsh
    call_remote m, hsh, *args, &blk
  end

  def call_remote(*a, &blk)
    remote.call *a, &blk
  end
end
