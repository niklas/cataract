class TorrentsController < InheritedResources::Base
  attr_accessor :offline

  respond_to :js, :html
  respond_to :json, only: [:index, :create, :progress] # ember, jquery.filedrop

  before_filter :refresh!, only: :show
  custom_actions :resource => :prepend

  layout 'library'

  def progress
    @torrents = Torrent.running_or_listed(params[:running])
    Torrent.remote.apply @torrents, [:up_rate, :down_rate, :size_bytes, :completed_bytes]
    render json: @torrents, each_serializer: TorrentProgressSerializer
  end

  def create
    create! { torrents_path }
  end

  before_filter :play_with_flash, only: :index

  def play_with_flash
    flash[:lol] = 'trolololol'
    flash['rofl'] = 'Go go locats!'
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
