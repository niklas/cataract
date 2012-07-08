class TransferController < TorrentComponentController
  def create
    torrent.start!
    flash[:notice] = I18n.t('flash.transfer.create.notice', name: torrent.title)
    respond_with torrent
  end

  def destroy
    torrent.stop!
    flash[:notice] = I18n.t('flash.transfer.destroy.notice', name: torrent.title)
    respond_with torrent
  end
end
