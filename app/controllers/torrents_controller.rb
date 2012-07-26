class TorrentsController < InheritedResources::Base
  attr_accessor :offline

  respond_to :js, :html
  respond_to :json, only: [:index, :create] # ember, jquery.filedrop

  before_filter :refresh!, only: :show
  custom_actions :resource => :prepend

  layout 'library'

  def progress
    @torrents = Torrent.running_or_listed(params[:running])
    @torrents.each(&:refresh)
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
