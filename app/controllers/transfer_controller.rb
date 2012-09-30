class TransferController < TorrentComponentController
  respond_to :json

  Fields = [:up_rate, :down_rate, :size_bytes, :completed_bytes]

  rescue_from Torrent::RTorrent::Offline do |exception|
    render status: 502, text: I18n.t('rtorrent.exceptions.offline')
  end

  before_filter :clear_transfer_cache

  def index
    render json: collection, each_serializer: TransferSerializer, root: 'transfers'
  end

  def show
    render_json
  end

  def create
    torrent.start!
    flash[:notice] = I18n.t('flash.transfer.create.notice', name: torrent.title)
    render_json
  end

  def destroy
    torrent.stop!
    flash[:notice] = I18n.t('flash.transfer.destroy.notice', name: torrent.title)
    render json: torrent
  end

  private
  def render_json
    resource.fetch! Fields
    render json: resource, serializer: TransferSerializer
  end

  def collection
    @transfers ||= Torrent.running_or_listed(params[:running]).tap do |torrents|
      authorize! :index, Torrent
      Torrent.remote.apply torrents, Fields
    end.map(&:transfer)
  end
end
