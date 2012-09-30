# inherit from this to save some typing
class TorrentComponentController < InheritedResources::Base
  belongs_to :torrent, optional: true
  respond_to :json
  before_filter :refresh_torrent, except: [:index]
  load_and_authorize_resource except: [:index]

  # FIXME: ember-data does not support nested resources yet, so we have to jump
  # through hoops finding the torrent

  private
  def torrent
    @torrent ||= Torrent.find( params[:id] || resource_params.first[:id] )
  end

  helper_method :torrent

  def refresh_torrent
    torrent.refresh!
  end

  def resource
    @resource ||= torrent.send(resource_instance_name)
  end

end
