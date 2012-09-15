class TorrentsController < InheritedResources::Base
  attr_accessor :offline

  respond_to :json, only: [:index, :show, :create, :progress] # ember, jquery.filedrop

  before_filter :refresh!, only: :show
  custom_actions :resource => :prepend

  layout 'library'

  def payload
    render json: resource.payload, serializer: PayloadSerializer
  end

  def progress
    @torrents = Torrent.running_or_listed(params[:running])
    Torrent.remote.apply @torrents, [:up_rate, :down_rate, :size_bytes, :completed_bytes]
    render json: @torrents.map(&:transfer), each_serializer: TransferSerializer
  end

  def create
    create! { torrents_path }
  end

  private
  def collection
    @torrents ||= search.results
  end

  def refresh!
    if request.xhr?
      resource.refresh!
    end
    true
  end
end
