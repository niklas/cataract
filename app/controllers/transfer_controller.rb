class TransferController < TorrentComponentController
  respond_to :json

  def create
    torrent.start!
    flash[:notice] = I18n.t('flash.transfer.create.notice', name: torrent.title)
    render json: torrent, serializer: TorrentProgressSerializer
  end

  def destroy
    torrent.stop!
    flash[:notice] = I18n.t('flash.transfer.destroy.notice', name: torrent.title)
    render json: torrent
  end
end
