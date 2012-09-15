# inherit from this to save some typing
class TorrentComponentController < InheritedResources::Base
  respond_to :json
  before_filter :refresh_torrent, except: [:index]

  private
  def torrent
    @torrent ||= Torrent.find params[:id]
  end

  helper_method :torrent

  def refresh_torrent
    torrent.refresh!
  end

  def resource
    @resource ||= torrent.send(resource_instance_name)
  end

end
