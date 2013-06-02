# inherit from this to save some typing
class TorrentComponentController < InheritedResources::Base
  belongs_to :torrent, optional: true
  respond_to :json
  before_filter :refresh_torrent, except: [:index]
  load_and_authorize_resource except: [:index], class: false

  rescue_from Torrent::RTorrent::Offline do |exception|
    render status: 502, text: I18n.t('rtorrent.exceptions.offline')
  end

  # FIXME: Ember-Emu cannot delete nested resources yet
  private
  def torrent
    @torrent ||= parent || Torrent.find( params[:id] || resource_params.first[:torrent_id] )
  end

  helper_method :torrent

  def refresh_torrent
    torrent.refresh!
  end

  def resource
    @resource ||= torrent.send(resource_instance_name)
  end


  def build_resource
    resource
  end
end
