class TorrentsController < InheritedResources::Base
  attr_accessor :offline

  respond_to :json, only: [:index, :show, :create, :progress] # ember, jquery.filedrop

  before_filter :refresh!, only: :show

  layout 'library'

  def index
    respond_to do |format|
      format.html do
        index!
      end
      format.json do
        publish_message "#{collection.length} torrents fetched"
        @updated = collection.first
        if !@updated.present? || stale?(:etag => @updated, :last_modified => @updated.updated_at)
          index!
        end
      end
    end
  end

  def create
    create! { torrents_path }
  end

  def destroy
    resource.stop! if resource.stoppable?
    destroy! do |success|
      success.json do
        render status: 204
      end
    end
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
                    if running = params[:running]
                      recent = recent.running_or_listed
                    end
                    if directory_id = params[:directory_id]
                      recent = recent.where(content_directory_id: directory_id.split(',').map(&:to_i))
                    end
                    if with_content = params[:with_content]
                      recent = recent.where(payload_exists: true)
                    end
                    recent
                  end
  end

  def fields_for_collection
    [:id, :title, :info_hash, :filename, :status, :content_directory_id, :file, :url, :created_at, :updated_at, :payload_exists]
  end

  def search_params
    super.merge(per: nil)
  end

  def refresh!
    if request.xhr?
      resource.refresh!
    end
    true
  end

  def interpolation_options
    { torrent: resource.title, error_messages: resource.errors.full_messages.to_sentence }
  end
end
