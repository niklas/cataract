class ContentController < InheritedResources::Base
  belongs_to :torrent, :singleton => true

  respond_to :js, :html

  before_filter :get_actual_size, :only => [:destroy]

  private
  def torrent
    parent
  end
  helper_method :torrent

  def torrent_decorator
    @torrent_decorator ||= TorrentDecorator.new(torrent)
  end

  def get_actual_size
    @actual_size = resource.actual_size
  end

  def interpolation_options
    { bytes: torrent_decorator.human_bytes(@actual_size) }
  end

end

