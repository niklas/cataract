class TransferController < TorrentComponentController
  respond_to :json

  def index
    torrents = Torrent.running_or_listed(params[:running])
    Torrent.remote.apply torrents, [:up_rate, :down_rate, :size_bytes, :completed_bytes]
    render json: torrents.map(&:transfer), each_serializer: TransferSerializer, root: 'transfers'
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
    render_json
  end

  private
  def render_json
    render json: resource, serializer: TransferSerializer
  end
end
