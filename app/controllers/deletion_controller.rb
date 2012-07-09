class DeletionController < TorrentComponentController
  private

  def interpolation_options
    { torrent: parent.title }
  end

  def resource_request_name
    :torrent_deletion
  end
end
