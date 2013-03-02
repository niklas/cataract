class MoveController < TorrentComponentController
  def index
    render json: collection, each_serializer: MoveSerializer, root: 'moves'
  end

  private

  def interpolation_options
    { torrent: torrent.title, target: resource.target_name }
  end

  def build_resource
    @resource ||= torrent.build_move(resource_params.first.except(:id))
  end
end
