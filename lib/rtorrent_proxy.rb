# This Class represents the glue between 
# the ActiveRecord Model Torrent and the 
# XMLRPC Client/RTorrent wrapper

class RTorrentProxy

  attr_reader :model, :remote

  def initialize(model,remote)
    @model = model    # the ActiveRecord::Base
    @remote = remote  # the XMLRPC wrapper
  end

  def method_missing(meth,*args,&blk)
    case meth.to_s
    when /^(.+)=$/    # setters
      m = "set_d_#{$1}"
      if remote.remote_respond_to? m
        return with_model(m, *args, &blk)
      end
    when /^(.+)!$/    # commands (for torrent)
      m = "d_#{$1}"
      if remote.remote_respond_to? m
        return with_model(m, *args, &blk)
      end
    when /^(.+)\?$/    # booleans? (for torrent)
      m = "get_d_is_#{$1}"
      if remote.remote_respond_to? m
        return with_model(m, *args, &blk).to_i > 0
      end
    else              # normal commands
      if remote.remote_respond_to? meth
        return remote.call(meth, *args, &blk)
      end
                      # getters 
      m = "get_d_#{meth}"
      if remote.remote_respond_to? m
        return with_model(m, *args, &blk)
      end
    end
    raise NoMethodError, "no such method: #{meth.to_s}"
  end

  # overload the ruby's #load *shiver* to load the torrent into rtorrent
  def load(path)
    remote.call 'load', path
  end

  private
  def with_model(m,*args,&blk)
    hsh = model.info_hash rescue nil
    raise TorrentHasNoInfoHash unless hsh
    remote.call m, hsh, *args, &blk
  end
end
