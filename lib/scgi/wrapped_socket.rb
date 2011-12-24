require 'scgi/wrapper'

class SCGI::WrappedSocket

  attr_accessor :sock, :uri, :method

  def initialize( sock, uri, method="POST" )
    @sock, @uri, @method = sock, uri, method
  end

  def write(x)
    msg = SCGI::Wrapper.wrap(x,@uri,@method)
    r = @sock.write(msg)
    if r != msg.length then
      raise IOException, "Not all the data has been sent (#{r}/#{msg.length})"
    end 
    x.length
  end 

  def read()
    data = @sock.read()
    # receiving an html response (very dumb parsing)
    # divided in 2
    # 1 -> status + headers
    # 2 -> data
    data.split("\r\n\r\n").last
  end

end


