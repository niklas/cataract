class Torrent
  extend ActiveSupport::Memoizable
  def is_episode?
    !series_name.blank?
  end

  def series_name
    Directory.for_series.subdir_names.find do |subdir|
      toks = subdir.split(/\W+/)
      self.filename =~ Regexp.new toks.join(".*")
    end if Directory.for_series
  end
  memoize :series_name
end

