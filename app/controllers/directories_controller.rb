class DirectoriesController < InheritedResources::Base
  belongs_to :disk, optional: true
  respond_to :js, :html

  load_and_authorize_resource

  def create
    create! do
      if resource.is_root?
        directories_path
      else
        directory_path(resource.parent)
      end
    end
  end

  private
  def interpolation_options
    { name: resource.name }
  end
end
