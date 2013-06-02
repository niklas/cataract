class DeletionController < TorrentComponentController
  def create
    create! do |success|
      success.json { render json: { } }
    end
  end

  def update
    # we must provide the id for deletion, as Emu cannot DELETE nested singletons
    create
  end
  private

  def interpolation_options
    { torrent: torrent.title }
  end

  def resource
    @resource || torrent.build_deletion(resource_params.first.except(:id))
  end

end
