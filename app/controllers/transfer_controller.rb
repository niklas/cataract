class TransferController < TorrentComponentController
  def create
    torrent.start!
    respond_with torrent
  end

  def destroy
    torrent.stop!
    respond_with torrent
  end
end
