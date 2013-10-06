class MovesController < TorrentComponentController
  private

  def interpolation_options
    { torrent: torrent.title, target: resource.target_name }
  end

  def build_resource
    @resource ||= torrent.build_move(resource_params.first.except(:id))
  end
end
