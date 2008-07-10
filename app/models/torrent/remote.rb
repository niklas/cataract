class Torrent
  def uri
    if @uri
      @uri
    else
      u = url
      u = URI.escape u
      u = URI.escape u, /[\[\]]/
      @uri = URI.parse(u)
    end
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

  def fetchable_message
    if url.blank?
      'Please give direct URL to torrent (from Link to Download).'
    elsif fetchable?
      "Ready for download."
    else
      "Bad URL: #{errors.on(:url)}"
    end
  end

  def fetch_by_url
    if resp = Net::HTTP::get_response(uri) and resp.is_a?(Net::HTTPSuccess)
      unless filename
        update_attribute :filename, filename_from_http_response(resp)
      end
      File.open(fullpath(:fetching), 'w') do |file|
        file.write resp.body
      end
      return self
    else
      raise "could not fetch: #{resp.inspect}"
      return false
    end
  end

  private

  def filename_from_http_response(resp)
    fn = if cdis = resp['content-disposition']
           cdis.sub(/^.*filename=(.+)$/,'\1').
                sub(/^"+/, '').
                sub(/"+$/, '')
         elsif !self.url.blank?
           self.url.sub(/.*\//,'')
         else
           %Q[downloaded-torrent-#{self.id}]
         end
    fn += '.torrent' unless fn =~ /\.torrent$/
    fn
  end

end
