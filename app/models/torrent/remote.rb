class Torrent

  validates_uniqueness_of :url, on: :create, allow_blank: true
  before_validation :set_filename_from_url, on: :create, if: :remote?

  temporary_predicate :fetch_automatically
  before_validation :fetch_from_url, :if => :fetch_automatically?

  class Download < Struct.new(:torrent)
    attr_reader :payload
    attr_reader :file
    attr_reader :response

    delegate :read, to: :file

    def go!
      @response = nil
      if fetch_url(torrent.parsed_url) and response.is_a?(Net::HTTPSuccess)
        unless torrent.filename.present?
          torrent.filename = filename_from_response
        end
        @payload = response.body
        @file = StringIO.new @payload
        true
      end
    end

    def has_payload?
      @payload && !@payload.empty?
    end

    def original_filename
      filename_from_response
    end

    private

    # TODO DRY agains FetchRSSFeed
    def fetch_url(url, limit=5)
      url = URI.parse(url) unless url.is_a?(URI)
      @response = Net::HTTP::get_response(url)
      Rails.logger.debug { "fetching #{url} => #{@response.code} #{@response.inspect}" }
      case @response
      when Net::HTTPRedirection
        if limit > 0
          new_url = @response['location']
          Rails.logger.debug { "following redirect to #{new_url}" }
          fetch_url new_url, limit - 1
        else
          torrent.errors.add :url, "unfetchable: redirect loop"
          false
        end
      when Net::HTTPSuccess
        Rails.logger.debug { "fetched #{@response.inspect}" }
        @response
      else
        Rails.logger.debug { "unfetchable: #{@response.inspect}" }
        torrent.errors.add :url, "unfetchable: #{@response.inspect}"
        false
      end
    rescue URI::InvalidURIError
      # often there are special chars (unescaped) in the filename
      escaped = url.sub(%r~(?<=/)[^/]+$~) { |m| CGI.escape(m) }
      fetch_url(escaped, limit)
    rescue SocketError, Errno::ECONNREFUSED, NoMethodError => e
      Rails.logger.debug { "unfetchable: #{e}" }
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
    if url.present? && !file_exists? && !downloaded?
      if download.go!
        self.file = download
        self.status = :archived
      end
    end
  rescue URI::InvalidURIError => e
    false
  end

  alias_method :fetch!, :fetch_from_url

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
    download.has_payload?
  end

  def set_filename_from_url
    if filename.blank? && url.present?
      self.filename = File.basename url
    end
  rescue Exception => e
  end

end
