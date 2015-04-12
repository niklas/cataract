class ExtractFilenameFromURL
  include Interactor

  def call
    url = context.url

    if url.present?
      fn = extract_from url
      unless fn.present?
        context.fail! message: "Extracted name was blank"
      else
        fn += '.torrent' unless fn.ends_with?('.torrent')
        context.filename = fn
      end
    else
      context.fail! message: "Must give a non-blank url"
    end
  end

  def extract_from(url)
    url = URI.parse(url) unless url.is_a?(URI)
    if url.query
      if url.query =~ /title=(.*)$/
        $1
      else
        url.query.sub(/.*\//,'')
      end
    else
      File.basename(url.to_s).sub(/.*\//,'')
    end
  end
end
