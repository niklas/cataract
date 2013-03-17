class DirectoriesController < InheritedResources::Base
  belongs_to :disk, optional: true
  respond_to :json

  load_and_authorize_resource except: [:index]

  def create
    create!
  end

  def update
    update!
  end

  protected
  def interpolation_options
    { name: resource.name }
  end

  def collection
    authorize! :index, Directory
    @directories ||= end_of_association_chain.order('name, disk_id').includes(:disk)
  end

end
