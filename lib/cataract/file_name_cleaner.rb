class Cataract::FileNameCleaner

  # * removes some 1337 comments about format/group in the filename
  # * cuts the .torrent extention
  # * tranforms interpunctuations into spaces
  # * kills renaming spaces
  def self.clean(name)
    return unless name.present?
    tags = [].tap do |tags|
      tags << '720p' if name =~ /720p/i
    end
    [name.
      gsub(/(?:dvd|xvid|divx|hdtv|cam|fqm|eztv|x264\b)/i,'').
      sub(/^_kat\.ph_/,'').
      sub(/^_[^_]+\.to_/,'').
      gsub(/\[.*?\]/,'').
      gsub(/\(.*?\)/,'').
      sub(/\d{5,}.TPB/,'').
      sub(/\.?torrent$/i,'').
      gsub(/[._-]+/,' ').
      gsub(/\s{2,}/,' ').
      rstrip.lstrip, *tags].join(" ")
  end

end

