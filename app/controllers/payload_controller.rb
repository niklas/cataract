class PayloadController < TorrentComponentController
  respond_to :json

  before_filter :get_actual_size, only: [:destroy]
  after_action :publish_destroy,  only: [:destroy]

  def show
    render json: resource, serializer: PayloadSerializer
  end

  private
  def get_actual_size
    @actual_size = resource.actual_size
  end

  def interpolation_options
    { bytes: human_actual_size }
  end

  def publish_destroy
    publish torrent.content_directory
    super resource
  end

  def human_actual_size
    self.class.helpers.human_bytes(@actual_size).sub(/ytes$/,'')
  end

end

