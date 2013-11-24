class DetectedDirectoriesController < InheritedResources::Base
  respond_to :json

  def index
    authorize! :index, Directory
    render json: collection, each_serializer: DetectedDirectorySerializer
  end
  private
  def collection
    @detected_directories ||= parent.detected_directories
  end

  def parent
    if    id = params[:directory_id]
      Directory.find(id)
    elsif id = params[:disk_id]
      Disk.find(id)
    else
      raise "cannot find parent to detect directories"
    end
  end
end
