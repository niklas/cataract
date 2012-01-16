class Torrent
  attr_accessor :fetch_automatically

  before_validation :fetch_from_url, :if => :fetch_automatically

  class Download < Struct.new(:torrent)
    attr_reader :payload
    attr_reader :response

    def go!
      @response = nil
      if fetch_url(torrent.parsed_url) and response.is_a?(Net::HTTPSuccess)
        unless torrent.filename.present?
          torrent.filename = filename_from_response
        end
        @payload = response.body
        true
      end
    end

    private

    def fetch_url(url)
      @response = Net::HTTP::get_response(url)
    rescue SocketError, Errno::ECONNREFUSED, NoMethodError => e
      torrent.errors.add :url, "unfetchable: #{e}"
      false
    end

    def filename_from_response
      fn = if cdis = response['content-disposition']
             cdis.sub(/^.*filename=(.+)$/,'\1').
                  sub(/^"+/, '').
                  sub(/"+$/, '')
           elsif !torrent.url.blank?
             torrent.url.sub(/.*\//,'')
           else
             %Q[downloaded-torrent-#{torrent.id}]
           end
      fn += '.torrent' unless fn.ends_with?('.torrent')
      fn
    end
  end

  def fetch_from_url
    if url && !file_exists?
      ensure_directory
      download.go!
    end
  rescue URI::InvalidURIError => e
    false
  end

  def parsed_url
    URI.parse escaped_url
  end

  def escaped_url
    if u = url
      u = URI.escape u
      u = URI.escape u, /[\[\]]/
    end
  end

  def download
    @download ||= Download.new(self)
  end

  def downloaded?
    @download.present? && @download.payload.present?
  end

  after_save :write_file_from_download, :if => :downloaded?

  def write_file_from_download
    File.open(path, 'w') { f.write download.payload }
  end

  def fetchable?(please_reload=false)
    return if url.blank?
    unless @fetchable.nil? || please_reload
      return @fetchable
    end
    @fetchable =
      begin
        Net::HTTP.start(uri.host, uri.port) do |http|
          resp = http.head(uri.path)
          if resp.is_a?(Net::HTTPSuccess) and (resp['content-type'] =~ /application\/x-bittorrent/i)
            self.filename ||= filename_from_http_response(resp)
            resp
          else
            errors.add :url, "HTTP Error: #{resp.inspect}, Content-type: #{resp['content-type']}"
            false
          end
        end
      rescue URI::InvalidURIError
        errors.add :url, "is not valid (#{url.to_s})"
        false
      rescue SocketError, NoMethodError => e
        errors.add :url, "unfetchable (#{e.to_s})"
        false
      end
  end

end
