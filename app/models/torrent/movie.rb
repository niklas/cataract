class Torrent
  extend ActiveSupport::Memoizable
  MovieRegexp = /\.(avi|mkv|vob)$/
  def is_episode?
    !series_name.blank?
  end

  def series_name
    Directory.for_series.subdir_names.find do |subdir|
      self.filename =~ Regexp.new(subdir.split(/\W+/).join(".*"))
    end if Directory.for_series
  end
  memoize :series_name

  def is_movie?
    content_filenames.any? {|c| c=~ MovieRegexp}
  end
  memoize :is_movie?
end

