class Torrent
  def is_episode?
    !series_name.blank?
  end

  def series_name
    @series ||=
      Directory.for_series.subdir_names.find do |subdir|
        toks = subdir.split(/[\._ ]/)
        self.filename =~ %r[#{toks.join(".*")}]
      end
  end
end

