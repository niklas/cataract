class TransferController < TorrentComponentController
  respond_to :json

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
