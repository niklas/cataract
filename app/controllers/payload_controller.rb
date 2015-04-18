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
    { bytes: PayloadSerializer.new(resource).human_bytes(@actual_size) }
  end

  def publish_destroy
    super resource
  end

end

