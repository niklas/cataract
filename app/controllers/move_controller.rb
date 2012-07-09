class MoveController < TorrentComponentController
  private

  def interpolation_options
    { torrent: parent.title, target: resource.target_name }
  end
end
