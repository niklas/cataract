require 'scgi'

class SCGI::Wrapper

  def self.wrap( content, uri, method="POST", headers=[] )
    null="\0"
    header = "CONTENT_LENGTH\0#{content.length}\0SCGI#{null}1\0REQUEST_METHOD\0#{method}\0REQUEST_URI\0#{uri}\0"
    headers.each do |h,v|
      header << "#{h}\0#{v}\0"
    end
    "#{header.length}:#{header},#{content}"
  end

end

