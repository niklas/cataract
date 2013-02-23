class DetectedDirectoriesController < InheritedResources::Base
  respond_to :json
  belongs_to :directory

  def index
    authorize! :index, Directory
    render json: collection, each_serializer: DetectedDirectorySerializer, root: 'detected_directories'
  end
  private
  def collection
    @detected_directories ||= parent.detected_directories
  end
end
