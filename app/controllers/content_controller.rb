class ContentController < TorrentComponentController
  before_filter :get_actual_size, :only => [:destroy]

  private
  def get_actual_size
    @actual_size = resource.actual_size
  end

  def interpolation_options
    { bytes: torrent_decorator.human_bytes(@actual_size) }
  end

end

