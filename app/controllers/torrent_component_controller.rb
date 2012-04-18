# inherit from this to save some typing
class TorrentComponentController < InheritedResources::Base
  belongs_to :torrent, :singleton => true
  respond_to :js, :html

  private
  def torrent
    parent
  end

  def torrent_decorator
    @torrent_decorator ||= TorrentDecorator.new(torrent)
  end

  helper_method :torrent

end
