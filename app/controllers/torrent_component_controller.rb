# inherit from this to save some typing
class TorrentComponentController < InheritedResources::Base
  belongs_to :torrent, :singleton => true
  respond_to :js, :html
  before_filter :refresh_torrent

  private
  def torrent
    parent
  end

  def torrent_decorator
    @torrent_decorator ||= TorrentDecorator.new(torrent)
  end

  helper_method :torrent

  def refresh_torrent
    torrent.refresh!
  end

end
