class DeletionController < TorrentComponentController
  def create
    create! do |success|
      success.json { render json: { } }
    end
  end
  private

  def interpolation_options
    { torrent: torrent.title }
  end

  def build_resource
    @resource || torrent.build_deletion(resource_params.first.except(:id))
  end

end
