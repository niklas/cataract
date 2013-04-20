class TorrentsController < InheritedResources::Base
  attr_accessor :offline

  respond_to :json, only: [:index, :show, :create, :progress] # ember, jquery.filedrop

  before_filter :refresh!, only: :show
  custom_actions :resource => :prepend

  layout 'library'

  def index
    @updated = resource_class.order('updated_at').last
    if !@updated.present? || stale?(:etag => @updated, :last_modified => @updated.updated_at)
      index!
    end
  end

  def create
    create! { torrents_path }
  end

  private
  def collection
    @torrents ||= begin
                    recent = Torrent.select(fields_for_collection).includes(:content_directory => :disk).recent
                    if page = params[:page]
                      recent = recent.page(page).per(params[:per])
                    end
                    if age = params[:age]
                      recent = recent.aged(age)
                    end
                    recent
                  end
  end

  def fields_for_collection
    [:id, :title, :info_hash, :filename, :status, :content_directory_id, :file, :url]
  end

  def search_params
    super.merge(per: nil)
  end

  def refresh!
    if request.xhr?
      clear_transfer_cache

      resource.refresh!
    end
    true
  end
end
